//
//  WalletSortViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/26/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import RxCocoa
import RxFeedback
import RxSwift
import UIKit

private enum Constants {
    static let heightForFooter: CGFloat = 23
}

final class WalletSortViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    let visibilityButton = UIBarButtonItem(title: Localizable.WalletSort.Button.visibility,
                                           style: .plain,
                                           target: nil,
                                           action: nil)
    let positionButton = UIBarButtonItem(title: Localizable.WalletSort.Button.position,
                                           style: .plain,
                                           target: nil,
                                           action: nil)

    var presenter: WalletSortPresenterProtocol!

    private var sections: [WalletSort.ViewModel.Section] = []
    private var status: WalletSort.State.Status = .visibility    
    private let sendEvent: PublishRelay<WalletSort.Event> = PublishRelay<WalletSort.Event>()

    override func viewDidLoad() {
        super.viewDidLoad()

        createBackButton()

        title = Localizable.WalletSort.Navigationbar.title
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 15, 0)

        let feedback = bind(self) { owner, state -> Bindings<WalletSort.Event> in
            return Bindings(subscriptions: owner.subscriptions(state: state),
                            events: owner.events())
        }

        let readyViewFeedback: WalletSortPresenterProtocol.Feedback = { [weak self] _ in
            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf
                .rx
                .viewWillAppear
                .take(1)
                .map { _ in WalletSort.Event.readyView }
                .asSignal(onErrorSignalWith: Signal.empty())
        }

        presenter.system(feedbacks: [feedback, readyViewFeedback])    
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTopBarLine()
    }
}

// MARK: Feedback

fileprivate extension WalletSortViewController {
    func events() -> [Signal<WalletSort.Event>] {
       
        let tapVisibilityButtonEvent =
            visibilityButton
                .rx
                .tap
                .asSignal()
                .map { WalletSort.Event.setStatus(.visibility)}

        let tapPositionButtonEvent =
            positionButton
                .rx
                .tap
                .asSignal()
                .map { WalletSort.Event.setStatus(.position)}

        return [sendEvent.asSignal(),
                tapPositionButtonEvent,
                tapVisibilityButtonEvent]
    }

    func subscriptions(state: Driver<WalletSort.State>) -> [Disposable] {
        let subscriptionSections = state
            .drive(onNext: { [weak self] state in

                guard let strongSelf = self else { return }
                guard state.action != .none else { return }

                strongSelf.changeStatus(state.status)
                strongSelf.sections = state.sections
                strongSelf.tableView.reloadDataWithAnimationTheCrossDissolve()
            })

        return [subscriptionSections]
    }
}

// MARK: Change Status

private extension WalletSortViewController {
    func changeStatus(_ status: WalletSort.State.Status) {

        self.status = status
        tableView.isEditing = status == .visibility
        navigationItem.rightBarButtonItem = status == .visibility ? positionButton : visibilityButton
    }
}

// MARK: UITableViewDataSource

extension WalletSortViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
}

// MARK: UITableViewDelegate

extension WalletSortViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        let sectionModel = sections[section]
        guard sectionModel.kind == .favorities else { return nil }

        return tableView.dequeueAndRegisterHeaderFooter() as WalletSortSeparatorFooter
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

        let sectionModel = sections[section]
        guard sectionModel.kind == .favorities else { return CGFloat.minValue }

        return Constants.heightForFooter
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        let row = sections[indexPath.section].items[indexPath.row]

        switch row {
        case .asset:
            return WalletSortCell.cellHeight()

        case .favorityAsset:
            return WalletSortFavCell.cellHeight()
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = sections[indexPath.section].items[indexPath.row]

        switch row {
        case .asset(let asset):
            let cell: WalletSortCell = tableView.dequeueCell()
            let model: WalletSortCell.Model = .init(name: asset.name,
                                                    isMyWavesToken: asset.isMyWavesToken,
                                                    isVisibility: status == .visibility,
                                                    isHidden: asset.isHidden,
                                                    isGateway: asset.isGateway)
            cell.update(with: model)
            cell.buttonFav
                .rx
                .tap
                .do(onNext: { _ in
                    ImpactFeedbackGenerator.impactOccurred()
                })
                .map { WalletSort.Event.tapFavoriteButton(indexPath) }
                .bind(to: sendEvent)
                .disposed(by: cell.disposeBag)

            cell.changedValueSwitchControl = { [weak self] isOn in
                self?.sendEvent.accept(.tapHidden(indexPath))
            }
            
            return cell

        case .favorityAsset(let asset):
            let cell: WalletSortFavCell = tableView.dequeueCell()
            let model: WalletSortFavCell.Model = .init(name: asset.name,
                                                       isMyWavesToken: asset.isMyWavesToken,
                                                       isLock: asset.isLock,
                                                       isGateway: asset.isGateway)
            cell.update(with: model)
            cell.buttonFav
                .rx
                .tap
                .do(onNext: { _ in
                    ImpactFeedbackGenerator.impactOccurred()
                })
                .map { WalletSort.Event.tapFavoriteButton(indexPath) }
                .bind(to: sendEvent)
                .disposed(by: cell.disposeBag)
            
            return cell
        }
    }

    // MARK: Draging cells

    func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView,
                   shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {

        let sectionModel = sections[proposedDestinationIndexPath.section]
        guard sectionModel.kind == .all else { return IndexPath(row: 0, section: sourceIndexPath.section) }

        return proposedDestinationIndexPath
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

        sendEvent.accept(.dragAsset(sourceIndexPath: sourceIndexPath,
                                    destinationIndexPath: destinationIndexPath))
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {

        let sectionModel = sections[indexPath.section]
        return sectionModel.kind == .all
    }
}

extension WalletSortViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
}
