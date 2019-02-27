//
//  AliasesViewControlelr.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 29/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxFeedback
import RxSwift
import RxCocoa

private enum Constants {
    static let topBarHeight: CGFloat = 42;
    static let bottomPadding: CGFloat = 24;
    static let durationAnimation: TimeInterval = 0.24
}

final class AliasesViewController: UIViewController {

    typealias Types = AliasesTypes

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var aliasesInfoView: AliasesInfoView!
    @IBOutlet private var aliasesInfoViewTopLayot: NSLayoutConstraint!

    private lazy var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handlerTapGesture(tap:)))

    private var sections: [Types.ViewModel.Section] = []
    private var eventInput: PublishSubject<Types.Event> = PublishSubject<Types.Event>()
    private var isHiddenInfoView: Bool = true
    private var errorSnackKey: String?

    var presenter: AliasesPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()

        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)

        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView()
        tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: Constants.bottomPadding + Constants.topBarHeight, right: 0)

        aliasesInfoView.infoButtonDidTap = {
            self.needShowView()
        }

        aliasesInfoView.createButtonDidTap = {
            self.eventInput.onNext(.tapCreateAlias)
        }

        setupSystem()
    }

    private func needShowView() {
        if self.isHiddenInfoView {
            self.eventInput.onNext(.showCreateAlias)
            self.showInfoView()
        } else {
            self.eventInput.onNext(.hideCreateAlias)
            self.hideInfoView()
        }
    }

    private func showInfoView() {

        isHiddenInfoView = false
        let size = aliasesInfoView.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize)
        aliasesInfoViewTopLayot.constant = size.height
        aliasesInfoView.arrayButton.setImage(Images.arrowdown14Basic300.image, for: .normal)
        tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: Constants.bottomPadding + size.height, right: 0)

        UIView.animate(withDuration: Constants.durationAnimation, delay: 0, options: [.curveEaseInOut], animations: {
            self.view.layoutIfNeeded()
        })
    }

    private func hideInfoView() {

        isHiddenInfoView = true
        aliasesInfoViewTopLayot.constant = Constants.topBarHeight
        aliasesInfoView.arrayButton.setImage(Images.arrowup14Basic300.image, for: .normal)
        tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: Constants.bottomPadding + Constants.topBarHeight, right: 0)

        UIView.animate(withDuration: Constants.durationAnimation, delay: 0, options: [.curveEaseInOut], animations: {
            self.view.layoutIfNeeded()
        })
    }

    @objc func handlerTapGesture(tap: UITapGestureRecognizer) {
        needShowView()
    }
}

extension AliasesViewController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let location = gestureRecognizer.location(in: view)
        let frame = CGRect(x: aliasesInfoView.frame.origin.x, y: aliasesInfoView.frame.origin.y, width: aliasesInfoView.frame.width, height: Constants.topBarHeight)
        return frame.contains(location)
    }
}

// MARK: RxFeedback

private extension AliasesViewController {

    func setupSystem() {

        let uiFeedback: AliasesPresenterProtocol.Feedback = bind(self) { (owner, state) -> (Bindings<Types.Event>) in
            return Bindings(subscriptions: owner.subscriptions(state: state), events: owner.events())
        }

        let readyViewFeedback: AliasesPresenterProtocol.Feedback = { [weak self] _ in
            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf.rx.viewWillAppear.asObservable()
                .throttle(1, scheduler: MainScheduler.asyncInstance)
                .asSignal(onErrorSignalWith: Signal.empty())
                .map { _ in Types.Event.viewWillAppear }
        }

        presenter.system(feedbacks: [uiFeedback, readyViewFeedback])
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

        switch state.transactionFee {
        case .fee(let money):
            aliasesInfoView.update(with: .init(status: .fee(money), isEnabledCreateButton: state.isEnabledCreateAliasButton))

        case .progress:
            aliasesInfoView.update(with: .init(status: .progress, isEnabledCreateButton: state.isEnabledCreateAliasButton))
        }

        switch state.error {
        case .error(let error):

            switch error {
            case .globalError(let isInternetNotWorking):

                if isInternetNotWorking {
                    errorSnackKey = showWithoutInternetSnack { [weak self] in
                        self?.eventInput.onNext(.refresh)
                    }
                } else {
                    errorSnackKey = showErrorNotFoundSnack(didTap: { [weak self] in
                        self?.eventInput.onNext(.refresh)
                    })
                }
            case .internetNotWorking:
                errorSnackKey = showWithoutInternetSnack { [weak self] in
                    self?.eventInput.onNext(.refresh)
                }

            case .message(let text):
                errorSnackKey = showErrorSnack(title: text, didTap: { [weak self] in
                    self?.eventInput.onNext(.refresh)
                })

            case .notFound, .scriptError:
                errorSnackKey = showErrorNotFoundSnack(didTap: { [weak self] in
                    self?.eventInput.onNext(.refresh)
                })
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
            case .update:
                tableView.reloadData()
            case .none:
                break
            }
        }
    }
}


// MARK: UITableViewDataSource

extension AliasesViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let row = sections[indexPath]
        switch row {
        case .alias(let alias):
            let cell: AliasesAliasCell = tableView.dequeueCell()
            cell.update(with: .init(title: alias.name))
            return cell

        case .head:
            let cell: AliasesHeadCell = tableView.dequeueCell()
            return cell
        }
    }
}

// MARK: UITableViewDelegate

extension AliasesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        let row = sections[indexPath]
        switch row {
        case .alias(let alias):
            return AliasesAliasCell.viewHeight(model: .init(title: alias.name), width: tableView.frame.width)

        case .head:
            return AliasesHeadCell.viewHeight(model: (), width: tableView.frame.width)
        }
    }
}

// MARK: UIScrollViewDelegate

extension AliasesViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
}
