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

final class WalletSortViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    let visibilityButton = UIBarButtonItem(title: "Visibility",
                                           style: .plain,
                                           target: nil,
                                           action: nil)
    let positionButton = UIBarButtonItem(title: "Position",
                                           style: .plain,
                                           target: nil,
                                           action: nil)

    private let presenter: WalletSortPresenterProtocol = WalletSortPresenter()

    private var sections: [WalletSort.ViewModel.Section] = []
    private var status: WalletSort.State.Status = .visibility    
    private let sendEvent: PublishRelay<WalletSort.Event> = PublishRelay<WalletSort.Event>()

    override func viewDidLoad() {
        super.viewDidLoad()

        createBackButton()

        title = "Sorting"
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 15, 0)

        let feedback = bind(self) { owner, state -> Bindings<WalletSort.Event> in
            return Bindings(subscriptions: owner.subscriptions(state: state),
                            events: owner.events())
        }
        presenter.system(bindings: feedback)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTopBarLine()
    }
}

// MARK: Feedback

fileprivate extension WalletSortViewController {
    func events() -> [Signal<WalletSort.Event>] {
        let readyViewEvent = rx
            .sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapTo(())
            .take(1)
            .map { WalletSort.Event.readyView }
            .asSignal(onErrorSignalWith: Signal.empty())

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

        return [readyViewEvent,
                sendEvent.asSignal(),
                tapPositionButtonEvent,
                tapVisibilityButtonEvent]
    }

    func subscriptions(state: Driver<WalletSort.State>) -> [Disposable] {
        let subscriptionSections = state
            .drive(onNext: { [weak self] state in

                self?.changeStatus(state.status)
                self?.sections = state.sections
                self?.tableView.reloadData()
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

        return 23
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
                                                    isMyAsset: asset.isMyAsset,
                                                    isVisibility: status == .visibility,
                                                    isHidden: asset.isHidden,
                                                    isGateway: asset.isGateway)
            cell.update(with: model)
            cell.buttonFav
                .rx
                .tap
                .map { WalletSort.Event.tapFavoriteButton(indexPath) }
                .bind(to: sendEvent)
                .disposed(by: cell.disposeBag)

//            cell
//                .switchControl
//                .rx
//                .isOn
//                .map { _ in WalletSort.Event.tapHidden(indexPath) }
//                .bind(to: sendEvent)
//                .disposed(by: cell.disposeBag)


            return cell

        case .favorityAsset(let asset):
            let cell: WalletSortFavCell = tableView.dequeueCell()
            let model: WalletSortFavCell.Model = .init(name: asset.name,
                                                       isMyAsset: asset.isMyAsset,
                                                       isLock: asset.isLock,
                                                       isGateway: asset.isGateway)
            cell.update(with: model)
            cell.buttonFav
                .rx
                .tap
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
//            let stringToMove = sortItems[sourceIndexPath.row]
//            sortItems.remove(at: sourceIndexPath.row)
//            sortItems.insert(stringToMove, at: destinationIndexPath.row)
//
//            CATransaction.begin()
//            CATransaction.setCompletionBlock {
//                self.tableView.reloadData()
//            }
//            tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
//            CATransaction.commit()
    }
//
        func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {

            let sectionModel = sections[indexPath.section]
            guard sectionModel.kind == .all else { return false }

            return true
        }
}

extension WalletSortViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
}
