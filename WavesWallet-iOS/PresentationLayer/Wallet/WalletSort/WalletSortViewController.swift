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

    private let presenter: WalletSortPresenterProtocol = WalletSortPresenter()

    private var sections: [WalletSort.ViewModel.Section] = []
    private var status: WalletSort.State.Status = .visibility
    private let sendEvent: PublishRelay<WalletSort.Event> = PublishRelay<WalletSort.Event>()

    override func viewDidLoad() {
        super.viewDidLoad()

        createBackButton()

        title = "Sorting"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Visibility",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(changeStyle))

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

        return [readyViewEvent,
                sendEvent.asSignal()]
    }

    func subscriptions(state: Driver<WalletSort.State>) -> [Disposable] {
        let subscriptionSections = state
            .drive(onNext: { [weak self] state in

                self?.status = state.status
                self?.sections = state.sections
                self?.tableView.reloadData()
                self?.tableView.isEditing = state.status != .visibility
            })

        return [subscriptionSections]
    }
}

// MARK: Actions

extension WalletSortViewController {
    @objc func changeStyle() {
//        isVisibilityMode = !isVisibilityMode
//        navigationItem.rightBarButtonItem?.title = isVisibilityMode ? "Position" : "Visibility"
//
//        UIView.animate(withDuration: 0.3) {
//            for tableCell in self.tableView.visibleCells {
//                if let cell = tableCell as? WalletSortCell {
//                    cell.setupCellState(isVisibility: self.isVisibilityMode)
//                } else if let cell = tableCell as? WalletSortFavCell {
//                    let indexPath = self.tableView.indexPath(for: cell)
//                    if indexPath?.row != 0 {
//                        cell.setupCellState(isVisibility: self.isVisibilityMode)
//                    }
//                }
//            }
//        }
//        tableView.setEditing(!isVisibilityMode, animated: true)
    }

    @objc func addToFavourite(_ sender: UIButton) {
//        let index = sender.tag
//        let string = sortItems[index]
//        sortItems.remove(at: index)
//        favItems.append(string)
//
//        CATransaction.begin()
//        CATransaction.setCompletionBlock {
//            self.tableView.reloadData()
//        }
//        tableView.beginUpdates()
//        tableView.deleteRows(at: [IndexPath(row: index, section: Section.sort.rawValue)], with: .fade)
//        tableView.insertRows(at: [IndexPath(row: favItems.count - 1, section: Section.fav.rawValue)], with: .fade)
//        tableView.endUpdates()
//        CATransaction.commit()
    }

    @objc func removeFromFavourite(_ sender: UIButton) {
        let index = sender.tag

        if index == 0 {
            return
        }

//        let string = favItems[index]
//        favItems.remove(at: index)
//        sortItems.insert(string, at: 0)
//
//        CATransaction.begin()
//        CATransaction.setCompletionBlock {
//            self.tableView.reloadData()
//        }
//        tableView.beginUpdates()
//        tableView.deleteRows(at: [IndexPath(row: index, section: Section.fav.rawValue)], with: .fade)
//        tableView.insertRows(at: [IndexPath(row: 0, section: Section.sort.rawValue)], with: .fade)
//        tableView.endUpdates()
//        CATransaction.commit()
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
                                                    isVisibility: status == .visibility)
            cell.update(with: model)
//            cell.buttonFav.tag = indexPath.row
//            cell.buttonFav.addTarget(self, action: #selector(addToFavourite(_:)), for: .touchUpInside)
            return cell

        case .favorityAsset(let asset):
            let cell: WalletSortFavCell = tableView.dequeueCell()
            let model: WalletSortFavCell.Model = .init(name: asset.name,
                                                       isMyAsset: asset.isMyAsset,
                                                       isLock: asset.isLock,
                                                       isVisibility: status == .visibility)
            cell.update(with: model)
            //            cell.buttonFav.tag = indexPath.row
            //            cell.buttonFav.addTarget(self, action: #selector(removeFromFavourite(_:)), for: .touchUpInside)
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
