//
//  CreateAliasViewController.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 29/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxFeedback
import RxSwift
import RxCocoa

final class CreateAliasViewController: UIViewController {

    typealias Types = CreateAliasTypes

    @IBOutlet private var footerView: UIView!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var saveButton: UIButton!
    @IBOutlet private var indicatorView: UIActivityIndicatorView!

    private var sections: [Types.ViewModel.Section] = []
    private var eventInput: PublishSubject<Types.Event> = PublishSubject<Types.Event>()
    private var errorSnackKey: String?

    var presenter: CreateAliasPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()

        createBackButton()
        setupBigNavigationBar()
        navigationItem.title = Localizable.Waves.Createalias.Navigation.title

        navigationItem.barTintColor = .white

        saveButton.setBackgroundImage(UIColor.submit200.image, for: .disabled)
        saveButton.setBackgroundImage(UIColor.submit400.image, for: .normal)
        saveButton.setTitle(Localizable.Waves.Createalias.Button.Create.title, for: .normal)
        tableView.tableHeaderView = UIView()
        tableView.addSubview(footerView)
        setupSystem()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutFooterView()
        updateContentInset()
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let inputCell = self.inputCell else { return }
        DispatchQueue.main.async {
            inputCell.becomeFirstResponder()
        }
    }

    private func continueCreateAlias() {
        view.endEditing(true)
        eventInput.onNext(.createAlias)
    }

    @IBAction func handlerSaveButton() {
        continueCreateAlias()
    }

    private func updateContentInset() {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: footerView.frame.height, right: 0)
    }

    private func layoutFooterView() {
        let size = footerView.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize)
        let y = max(tableView.contentSize.height, tableView.frame.height) - size.height
        footerView.frame = CGRect.init(x: 0, y: y, width: tableView.frame.width, height: size.height)
    }

    private var inputCell: CreateAliasInputCell? {
        guard let visibleCells = tableView?.visibleCells else { return nil }
        let anyCell = visibleCells.map({ cell -> CreateAliasInputCell? in
            return cell as? CreateAliasInputCell
        }).compactMap { $0 }.first
        return anyCell
    }
}

// MARK: RxFeedback

private extension CreateAliasViewController {

    func setupSystem() {

        let uiFeedback: CreateAliasPresenterProtocol.Feedback = bind(self) { (owner, state) -> (Bindings<Types.Event>) in
            return Bindings(subscriptions: owner.subscriptions(state: state), events: owner.events())
        }

        let readyViewFeedback: CreateAliasPresenterProtocol.Feedback = { [weak self] _ in
            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf.rx.viewWillAppear.asObservable()
                .throttle(1, scheduler: MainScheduler.instance)
                .asSignal(onErrorSignalWith: Signal.empty())
                .map { _ in Types.Event.viewWillAppear }
        }

        let viewDidDisappearFeedback: CreateAliasPresenterProtocol.Feedback = { [weak self] _ in
            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf.rx.viewDidDisappear.asObservable()
                .throttle(1, scheduler: MainScheduler.instance)
                .asSignal(onErrorSignalWith: Signal.empty())
                .map { _ in Types.Event.viewDidDisappear }
        }

        presenter.system(feedbacks: [uiFeedback, readyViewFeedback, viewDidDisappearFeedback])
    }

    func events() -> [Signal<Types.Event>] {
        return [eventInput.asSignal(onErrorSignalWith: Signal.empty())]
    }

    func subscriptions(state: Driver<Types.State>) -> [Disposable] {

        let subscriptionSections = state.drive(onNext: { [weak self] state in

            guard let strongSelf = self else { return }

            strongSelf.updateView(with: state.displayState)
        })

        return [subscriptionSections]
    }

    func updateView(with state: Types.DisplayState) {

        self.sections = state.sections

        if state.isLoading {
            indicatorView.startAnimating()
        } else {
            indicatorView.stopAnimating()
        }

        saveButton.isEnabled = state.isEnabledSaveButton

        switch state.errorState {
        case .error(let error):

            switch error {
            case .globalError(let isInternetNotWorking):

                if isInternetNotWorking {
                    errorSnackKey = showWithoutInternetSnackWithoutAction()
                } else {
                    errorSnackKey = showErrorNotFoundSnackWithoutAction()
                }
            case .internetNotWorking:
                errorSnackKey = showWithoutInternetSnackWithoutAction()

            case .message(let text):
                errorSnackKey = showMessageSnack(title: text)

            case .notFound:
                errorSnackKey = showErrorNotFoundSnackWithoutAction()

            case .scriptError:
                TransactionScriptErrorView.show()
            }

        case .none:
            if let errorSnackKey = errorSnackKey {
                hideSnack(key: errorSnackKey)
            }

        case .waiting:
            break
        }

        if let action = state.action {
            switch action {
            case .reload:

                tableView.reloadData()
            case .update:

                guard let inputCell = self.inputCell else { return }
                guard let indexPath = tableView.indexPath(for: inputCell) else { return }

                if case .input(let text, let error) = sections[indexPath] {
                    inputCell.update(with: .init(text: text, error: error))
                }

            case .none:
                break
            }
        }
    }
}


// MARK: UITableViewDataSource

extension CreateAliasViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let row = sections[indexPath]
        switch row {
        case .input(let text, let error):
            let cell: CreateAliasInputCell = tableView.dequeueCell()
            cell.update(with: .init(text: text, error: error))

            cell
                .textFieldChangedValue
                .map { Types.Event.input($0) }
                .bind(to: self.eventInput)
                .disposed(by: cell.disposeBag)

            cell.textFieldShouldReturn
                .subscribe(weak: self, onNext: { (owner, _) in
                    owner.continueCreateAlias()
                })
                .disposed(by: cell.disposeBag)
            
            return cell
        }
    }
}

// MARK: UITableViewDelegate

extension CreateAliasViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        let row = sections[indexPath]
        switch row {
        case .input(let text, let error):
            return CreateAliasInputCell.viewHeight(model: .init(text: text, error: error), width: tableView.frame.width)
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.becomeFirstResponder()
    }
}

// MARK: UIScrollViewDelegate

extension CreateAliasViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
        layoutFooterView()
    }
}
