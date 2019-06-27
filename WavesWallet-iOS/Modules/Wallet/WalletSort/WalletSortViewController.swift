//
//  NewWalletSortViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/17/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit
import RxCocoa
import RxFeedback
import RxSwift
import DomainLayer

private enum Constants {
    static let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
    static let segmentedCellIdentifier = "SegmentedCell"
    static let segmentedHeight: CGFloat = 48
}

final class WalletSortViewController: UIViewController {
    
    @IBOutlet private weak var tableView: TableViewNoShadow!
    
    private let sendEvent: PublishRelay<WalletSort.Event> = PublishRelay<WalletSort.Event>()
    private var sections: [WalletSort.ViewModel.Section] = []
    private var status: WalletSort.Status = .position

    @IBOutlet private weak var segmentedControl: WalletSortSegmentedControl!
    @IBOutlet private weak var segmentedTopPosition: NSLayoutConstraint!
    
    var presenter: WalletSortPresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentedControl.delegate = self
        createBackButton()
        setupBigNavigationBar()
        title = Localizable.Waves.Walletsort.Navigationbar.title
        tableView.contentInset = Constants.contentInset
        setupFeedBack()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.segmentedCellIdentifier)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTopBarLine()
        navigationController?.navigationBar.backgroundColor = view.backgroundColor
    }
}

//MARK: - WalletSortSegmentedControlDelegate
extension WalletSortViewController: WalletSortSegmentedControlDelegate {
    
    func walletSortSegmentedControlDidChangeStatus(_ status: WalletSort.Status) {
        if self.status != status {
            
            if case WalletSort.Status.position = status {
                UseCasesFactory
                    .instance
                    .analyticManager
                    .trackEvent(.walletHome(.tokenSortingPosition))
            } else {
                UseCasesFactory
                    .instance
                    .analyticManager
                    .trackEvent(.walletHome(.tokenSortingVisability))
            }
            
            sendEvent.accept(.setStatus(status))
        }
    }
}

//MARK: - RXFeedBack
private extension WalletSortViewController {
    
    func setupFeedBack() {
        let feedback = bind(self) { owner, state -> Bindings<WalletSort.Event> in
            return Bindings(subscriptions: owner.subscriptions(state: state),
                            events: owner.events())
        }
        
        let readyViewFeedback: WalletSortPresenterProtocol.Feedback = { [weak self] _ in
            guard let self = self else { return Signal.empty() }
            return self
                .rx
                .viewWillAppear
                .take(1)
                .map { _ in WalletSort.Event.readyView }
                .asSignal(onErrorSignalWith: Signal.empty())
        }
        
        presenter.system(feedbacks: [feedback, readyViewFeedback])
    }
   
    func events() -> [Signal<WalletSort.Event>] {
        return [sendEvent.asSignal()]
    }
    
    func subscriptions(state: Driver<WalletSort.State>) -> [Disposable] {
        let subscriptionSections = state
            .drive(onNext: { [weak self] state in
                
                guard let self = self else { return }
                
                switch state.action {
                case .none:
                    return
                default:
                    break
                }
                
                self.sections = state.sections
                self.status = state.status
                self.tableView.isEditing = state.status == .position
                self.segmentedControl.update(with: state.status)
                
                switch state.action {
                case .move(let at, let to, let delete, let insert):
                    self.updateTableMove(moveAt: at, moveTo: to, delete: delete, insert: insert, movedRowAt: nil)
                
                case .updateMoveAction(let insertAt, let deleteAt, let movedRowAt):
                    self.updateTableMove(moveAt: nil, moveTo: nil, delete: deleteAt, insert: insertAt, movedRowAt: movedRowAt)
                    
                case .finishUpdateMoveAction(let movedRowAt):
                    self.updateMovedRow(movedRow: movedRowAt)
                    self.tableView.performBatchUpdates({
                        
                    }, completion: { (complete) in
                        self.tableView.reloadData()
                    })
                    
                case .refreshWithAnimation:
                    self.tableView.reloadDataWithAnimationTheCrossDissolve()

                case .refresh:
                    self.tableView.reloadData()

                default:
                    break
                }
                
            })
        
        return [subscriptionSections]
    }
}

//MARK: - UIScrollViewDelegate
extension WalletSortViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if isSmallNavigationBar {
            segmentedControl.addShadow()
        }
        else {
            segmentedControl.removeShadow()
        }
        
        let tableTopOffset = tableViewTopOffsetForBigNavBar(tableView).y

        if tableView.contentOffset.y < tableTopOffset {
            let diff = abs(tableView.contentOffset.y) - abs(tableTopOffset)
            segmentedTopPosition.constant = diff
        }
        else {
            segmentedTopPosition.constant = 0
        }
        
    }
}

//MARK: - UITableViewDelegate
extension WalletSortViewController: UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        sendEvent.accept(.moveAsset(from: sourceIndexPath, to: destinationIndexPath))
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {

        if proposedDestinationIndexPath.section == sections.firstIndex(where: {$0.kind == .top}) {
            if let favSectionIndex = sections.firstIndex(where: {$0.kind == .favorities}) {
                return IndexPath(row: 0, section: favSectionIndex)
            }
        }
        else if isEmptySection(at: proposedDestinationIndexPath) {
            return IndexPath(row: 0, section: proposedDestinationIndexPath.section)
        }
        return proposedDestinationIndexPath
    }

    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        
        let row = sections[indexPath.section].items[indexPath.row]
        return row.isMovable
    }
    
}

//MARK: - UITableViewDataSource
extension WalletSortViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let row = sections[indexPath.section].items[indexPath.row]
        switch row {
            
        case .top:
            return Constants.segmentedHeight
            
        case .emptyAssets(let model):
            return WalletSortEmptyAssetsCell.viewHeight(model: model, width: tableView.frame.size.width)
            
        case .separator(let isShowHiddenTitle):
            return WalletSortSeparatorCell.viewHeight(model: isShowHiddenTitle ? .title : .line,
                                                      width: tableView.frame.size.width)
            
        default:
            return WalletSortCell.viewHeight()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = sections[indexPath.section].items[indexPath.row]

        switch row {
    
        case .top:
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.segmentedCellIdentifier, for: indexPath)
            cell.backgroundColor = .clear
            return cell
            
        case .emptyAssets(let model):
            let cell: WalletSortEmptyAssetsCell = tableView.dequeueAndRegisterCell()
            cell.update(with: model)
            return cell
            
        case .separator(let isShowHiddenTitle):
            let cell: WalletSortSeparatorCell = tableView.dequeueAndRegisterCell()
            cell.update(with: isShowHiddenTitle ? .title : .line)
            return cell
            
        case .favorityAsset(let asset):
          
            let cell: WalletSortCell = tableView.dequeueAndRegisterCell()
            cell.update(with: cellModel(asset: asset, type: .favourite))
            addAction(cell: cell, asset: asset, indexPath: indexPath)
            return cell

        case .list(let asset):
          
            let cell: WalletSortCell = tableView.dequeueAndRegisterCell()
            cell.update(with: cellModel(asset: asset, type: .list))
            addAction(cell: cell, asset: asset, indexPath: indexPath)
            return cell
            
        case .hidden(let asset):
            
            let cell: WalletSortCell = tableView.dequeueAndRegisterCell()
            cell.update(with: cellModel(asset: asset, type: .hidden))
            addAction(cell: cell, asset: asset, indexPath: indexPath)
            return cell
        }
    }
}

//MARK: - UI
private extension WalletSortViewController {
 
    func isEmptySection(at indexPath: IndexPath) -> Bool {
        return sections[indexPath.section].items.filter({$0.asset != nil }).count == 0
    }
    
    func updateMovedRow(movedRow: IndexPath?) {
        
        if let movedRow = movedRow, let cell = self.tableView.cellForRow(at: movedRow) as? WalletSortCell {
            let section = self.sections[movedRow.section]
            
            if section.kind == .favorities {
                cell.showAnimationToFavoriteState()
            }
            else if section.kind == .list {
                cell.showAnimationToListState()
            }
            else if section.kind == .hidden {
                cell.showAnimationToHiddenState()
            }
        }
    }
    
    func animateTitleSeparatorCell(isShowTitle: Bool) {
        
        let listSectionIndex = sections.firstIndex(where: {$0.kind == .list}) ?? 0
        
        for cell in tableView.visibleCells {
            if let indexPath = tableView.indexPath(for: cell),
                let separatorRow = cell as? WalletSortSeparatorCell,
                indexPath.section == listSectionIndex {
                
                if isShowTitle {
                    separatorRow.showTitleWithAnimation()
                }
                else {
                    separatorRow.hideTitleWithAnimation()
                }
                break
            }
        }
    }
    
    func updateTableMove(moveAt: IndexPath?, moveTo: IndexPath?, delete: IndexPath?, insert: IndexPath?, movedRowAt: IndexPath?) {
        
        if let insert = insert, sections.firstIndex(where: {$0.kind == .hidden}) == insert.section {
            animateTitleSeparatorCell(isShowTitle: false)
        }
        else if let delete = delete, sections.firstIndex(where: {$0.kind == .hidden}) == delete.section {
            animateTitleSeparatorCell(isShowTitle: true)
        }
        
        updateMovedRow(movedRow: movedRowAt)
        
        tableView.performBatchUpdates({
            
            if let delete = delete {
                self.tableView.deleteRows(at: [delete], with: .fade)
            }
            if let insert = insert {
                self.tableView.insertRows(at: [insert], with: .fade)
            }
            if let at = moveAt, let to = moveTo {
                self.tableView.moveRow(at: at, to: to)
            }
        }, completion: { (complete) in
            self.tableView.reloadData()
        })
    }
    
    func cellModel(asset: WalletSort.DTO.Asset, type: WalletSortCell.AssetType) -> WalletSortCell.Model {
        return WalletSortCell.Model(name: asset.name,
                                    isMyWavesToken: asset.isMyWavesToken,
                                    isVisibility: status == .visibility,
                                    isHidden: asset.isHidden,
                                    isFavorite: asset.isFavorite,
                                    isGateway: asset.isGateway,
                                    icon: asset.icon,
                                    isSponsored: asset.isSponsored,
                                    hasScript: asset.hasScript,
                                    type: type)
    }
    
    func addAction(cell: WalletSortCell, asset: WalletSort.DTO.Asset, indexPath: IndexPath) {
        
        cell.didBlockAllActions = { [weak self] in
            guard let self = self else { return }
            for visibleCell in self.tableView.visibleCells {
                if let cell = visibleCell as? WalletSortCell {
                    cell.isBlockedCell = true
                }
            }
        }
        cell.favouriteButtonTapped = { [weak self] in
            guard let self = self else { return }
            self.sendEvent.accept(.setFavoriteAt(indexPath))
            
            
        }
        
        cell.changedValueSwitchControl = { [weak self]  in
            guard let self = self else { return }
            self.sendEvent.accept(.setHiddenAt(indexPath))
            
        }
    }
}
