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

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var saveButton: UIButton!
    @IBOutlet private var indicatorView: UIActivityIndicatorView!

    private var sections: [Types.ViewModel.Section] = []
    private var eventInput: PublishSubject<Types.Event> = PublishSubject<Types.Event>()

    var presenter: CreateAliasPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()

        createBackButton()
        setupBigNavigationBar()
        navigationItem.title = "New alias"
        navigationItem.barTintColor = .white

        saveButton.setBackgroundImage(UIColor.submit200.image, for: .disabled)
        saveButton.setBackgroundImage(UIColor.submit400.image, for: .normal)

        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView()

        setupSystem()
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
        case .input(let text):
            let cell: CreateAliasInputCell = tableView.dequeueCell()
            cell.update(with: .init(text: text))

            cell
                .textFieldChangedValue
                .map { Types.Event.input($0) }
                .bind(to: self.eventInput)
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
        case .input(let text):
            return CreateAliasInputCell.viewHeight(model: .init(text: text), width: tableView.frame.width)
        }
    }
}

// MARK: UIScrollViewDelegate

extension CreateAliasViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
}
