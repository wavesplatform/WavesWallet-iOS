//
//  File.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 11.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit

private enum Constants {
    static let animationDuration: TimeInterval = 0.34
}

protocol WalletDisplayDataDelegate: AnyObject {
    func tableViewDidSelect(indexPath: IndexPath)
    func showSearchVC(fromStartPosition: CGFloat)
}

final class WalletDisplayData: NSObject {
    private typealias Section = WalletTypes.ViewModel.Section
    private var assetsSections: [Section] = []
    private var leasingSections: [Section] = []
    
    private weak var scrolledTablesComponent: ScrolledContainerView!
    
    weak var delegate: WalletDisplayDataDelegate?
    weak var balanceCellDelegate: WalletLeasingBalanceCellDelegate?
    
    let tapSection: PublishRelay<Int> = PublishRelay<Int>()
    var completedReload: (() -> Void)?
    
    init(scrolledTablesComponent: ScrolledContainerView) {
        super.init()
        self.scrolledTablesComponent = scrolledTablesComponent
    }
    
    func apply(assetsSections: [WalletTypes.ViewModel.Section], leasingSections: [WalletTypes.ViewModel.Section], animateType: WalletTypes.DisplayState.ContentAction, completed: @escaping (() -> Void)) {
        
        self.assetsSections = assetsSections
        self.leasingSections = leasingSections
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completed()
        }
        
        switch animateType {
        case .none:
            break
            
        case .refresh(let animated):
            
            if animated {
                UIView.transition(with: scrolledTablesComponent, duration: Constants.animationDuration, options: [.transitionCrossDissolve], animations: {
                    self.scrolledTablesComponent.reloadData()
                }, completion: nil)
            } else {
                self.scrolledTablesComponent.reloadData()
            }
            
        case .collapsed(let index):
            
            self.scrolledTablesComponent.reloadSectionWithCloseAnimation(section: index)
            
            
        case .expanded(let index):
            
            self.scrolledTablesComponent.reloadSectionWithOpenAnimation(section: index)
            
        default:
            break
        }
        CATransaction.commit()
    }
    
    private func sections(by tableView: UITableView) -> [Section] {
        if tableView.tag == WalletTypes.DisplayState.Kind.assets.rawValue {
            return assetsSections
        }
        return leasingSections
    }
    
    private func searchTapped(_ cell: UITableViewCell) {
        
        if let indexPath = scrolledTablesComponent.visibleTableView.indexPath(for: cell) {
            
            let rectInTableView = scrolledTablesComponent.visibleTableView.rectForRow(at: indexPath)
            let rectInSuperview = scrolledTablesComponent.visibleTableView.convert(rectInTableView, to: AppDelegate.shared().window)
            
            delegate?.showSearchVC(fromStartPosition: rectInSuperview.origin.y)
        }
    }
    
    var isNeedSetupSearchBarPosition: Bool {
        
        return assetsSections.first(where: { (section) -> Bool in
            switch section.kind {
            case .search:
                return true
            default:
                return false
            }
        }) != nil &&
            scrolledTablesComponent.visibleTableView.tag == WalletTypes.DisplayState.Kind.assets.rawValue &&
            scrolledTablesComponent.contentSize.height > scrolledTablesComponent.frame.size.height &&
            scrolledTablesComponent.contentOffset.y + scrolledTablesComponent.smallTopOffset < scrolledTablesComponent.topOffset + WalletSearchTableViewCell.viewHeight() &&
            scrolledTablesComponent.contentOffset.y + scrolledTablesComponent.smallTopOffset > scrolledTablesComponent.topOffset
    }
}

// MARK: UITableViewDelegate
extension WalletDisplayData: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = sections(by: tableView)[indexPath.section].items[indexPath.row]
        
        switch item {
        case .search:
            let cell = tableView.dequeueAndRegisterCell() as WalletSearchTableViewCell
            cell.update(with: ())
            cell.searchTapped = { [weak self] in
                self?.searchTapped(cell)
            }
            return cell
            
        case .historySkeleton:
            return tableView.dequeueAndRegisterCell() as WalletHistorySkeletonCell
            
        case .balanceSkeleton:
            return tableView.dequeueAndRegisterCell() as WalletLeasingBalanceSkeletonCell
            
        case .assetSkeleton:
            return tableView.dequeueAndRegisterCell() as WalletAssetSkeletonCell
            
        case .balance(let balance):
            let cell: WalletLeasingBalanceCell = tableView.dequeueAndRegisterCell()
            cell.update(with: balance)
            cell.delegate = balanceCellDelegate
            return cell
            
        case .leasingTransaction(let transaction):
            let cell: WalletLeasingCell = tableView.dequeueAndRegisterCell()
            cell.update(with: transaction)
            return cell
            
        case .allHistory:
            let cell = tableView.dequeueAndRegisterCell() as WalletHistoryCell
            cell.update(with: ())
            return cell
            
        case .hidden:
            return tableView.dequeueAndRegisterCell() as EmptyCell
            
        case .asset(let model):
            let cell: WalletTableAssetsCell = tableView.dequeueAndRegisterCell()
            cell.update(with: model)
            return cell
            
        case .quickNote:
            let cell = tableView.dequeueAndRegisterCell() as WalletQuickNoteCell
            cell.setupLocalization()
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections(by: tableView).count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections(by: tableView)[section].items.count
    }
}

extension WalletDisplayData: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let item = sections(by: tableView)[indexPath.section].items[indexPath.row]
        switch item {
        case .historySkeleton:
            let skeletonCell: WalletHistorySkeletonCell = cell as! WalletHistorySkeletonCell
            skeletonCell.startAnimation()
            
        case .assetSkeleton:
            let skeletonCell: WalletAssetSkeletonCell = cell as! WalletAssetSkeletonCell
            skeletonCell.startAnimation()
            
        case .balanceSkeleton:
            let skeletonCell: WalletLeasingBalanceSkeletonCell = cell as! WalletLeasingBalanceSkeletonCell
            skeletonCell.startAnimation()
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let model = sections(by: tableView)[section]
        
        if let header = model.header {
            let view: WalletHeaderView = tableView.dequeueAndRegisterHeaderFooter()
            view.update(with: header)
            view.setupArrow(isExpanded: model.isExpanded, animation: false)
            
            view.arrowDidTap = { [weak self] in
                self?.tapSection.accept(section)
            }
            return view
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let model = sections(by: tableView)[section]
        
        if model.header == nil {
            return CGFloat.minValue
        } else {
            return WalletHeaderView.viewHeight()
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return self.tableView(tableView, heightForHeaderInSection: section)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.minValue
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.minValue
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let items = sections(by: tableView)[indexPath.section].items
        let row = items[indexPath.row]
        
        switch row {
            
        case .search:
            return WalletSearchTableViewCell.viewHeight()
            
        case .historySkeleton:
            return WalletHistorySkeletonCell.cellHeight()
            
        case .balanceSkeleton:
            return WalletLeasingBalanceSkeletonCell.cellHeight()
            
        case .asset:
            return WalletTableAssetsCell.cellHeight()
            
        case .assetSkeleton:
            return WalletAssetSkeletonCell.cellHeight()
            
        case .balance(let balance):
            return WalletLeasingBalanceCell.viewHeight(model: balance, width: tableView.frame.size.width)
            
        case .leasingTransaction:
            return WalletLeasingCell.cellHeight()
            
        case .allHistory:
            return WalletHistoryCell.cellHeight()
            
        case .hidden:
            return CGFloat.minValue
            
        case .quickNote:
            return WalletQuickNoteCell.cellHeight(with: tableView.frame.width)
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView(tableView, heightForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.tableViewDidSelect(indexPath: indexPath)
    }
}

fileprivate extension WalletTypes.ViewModel.Section {
    
    var header: String? {
        
        switch kind {
        case .info:
            return Localizable.Waves.Wallet.Section.quickNote
            
        case .transactions(let count):
            return Localizable.Waves.Wallet.Section.activeNow(count)
            
        case .spam(let count):
            return Localizable.Waves.Wallet.Section.spamAssets(count)
            
        case .hidden(let count):
            return Localizable.Waves.Wallet.Section.hiddenAssets(count)
            
        default:
            return nil
        }
    }
}
