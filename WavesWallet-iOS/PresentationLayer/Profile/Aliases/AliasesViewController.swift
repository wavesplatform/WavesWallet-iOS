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
}

final class AliasesViewController: UIViewController {

    typealias Types = AliasesTypes

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var aliasesInfoView: AliasesInfoView!
    @IBOutlet private var aliasesInfoViewTopLayot: NSLayoutConstraint!

    private var sections: [Types.ViewModel.Section] = []
    private var eventInput: PublishSubject<Types.Event> = PublishSubject<Types.Event>()
    private var isHiddenInfoView: Bool = true

    var presenter: AliasesPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView()
        tableView.contentInset = UIEdgeInsetsMake(0, 0, Constants.bottomPadding + Constants.topBarHeight, 0)

        aliasesInfoView.infoButtonDidTap = {
            if self.isHiddenInfoView {
                self.showInfoView()
            } else {
                self.hideInfoView()
            }
        }

        setupSystem()
    }

    private func showInfoView() {

        isHiddenInfoView = false
        let size = aliasesInfoView.systemLayoutSizeFitting(UILayoutFittingExpandedSize)
        aliasesInfoViewTopLayot.constant = size.height
        aliasesInfoView.arrayButton.setImage(Images.arrowdown14Basic300.image, for: .normal)
        tableView.contentInset = UIEdgeInsetsMake(0, 0, Constants.bottomPadding + size.height, 0)

        UIView.animate(withDuration: 0.24, delay: 0, options: [.curveEaseInOut], animations: {
            self.view.layoutIfNeeded()
        }) { _ in

        }
    }

    private func hideInfoView() {

        isHiddenInfoView = true
        aliasesInfoViewTopLayot.constant = Constants.topBarHeight
        aliasesInfoView.arrayButton.setImage(Images.arrowup14Basic300.image, for: .normal)
        tableView.contentInset = UIEdgeInsetsMake(0, 0, Constants.bottomPadding + Constants.topBarHeight, 0)

        UIView.animate(withDuration: 0.24, delay: 0, options: [.curveEaseInOut], animations: {
            self.view.layoutIfNeeded()
        }) { _ in

        }
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
                .throttle(1, scheduler: MainScheduler.instance)
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
