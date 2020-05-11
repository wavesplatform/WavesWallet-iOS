//
//  File.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 11.07.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
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
    func withdrawTapped()
    func depositTapped()
    func tradeTapped()
    func buyTapped()
    func sortButtonTapped()
    func openStakingFaq(fromLanding: Bool)
    func openTw(_ sharedText: String)
    func openFb(_ sharedText: String)
    func openVk(_ sharedText: String)
    func startStakingTapped()
}

// Refactor method
final class WalletDisplayData: NSObject {
    private typealias Section = WalletTypes.ViewModel.Section
    private var assetsSections: [Section] = []
    private var leasingSections: [Section] = []
    private var stakingSections: [Section] = []
    
    private weak var scrolledTablesComponent: ScrolledContainerView!
    private let displays: [WalletTypes.DisplayState.Kind]
    
    weak var delegate: WalletDisplayDataDelegate?
    weak var balanceCellDelegate: WalletLeasingBalanceCellDelegate?
    
    let tapSection: PublishRelay<Int> = PublishRelay<Int>()
    var completedReload: (() -> Void)?
    
    internal var isDisplayInvesting: Bool = false
    
    init(scrolledTablesComponent: ScrolledContainerView,
         displays: [WalletTypes.DisplayState.Kind]) {
        self.displays = displays
        super.init()
        self.scrolledTablesComponent = scrolledTablesComponent
    }
    
    func apply(assetsSections: [WalletTypes.ViewModel.Section],
               leasingSections: [WalletTypes.ViewModel.Section],
               stakingSections: [WalletTypes.ViewModel.Section],
               animateType: WalletTypes.DisplayState.ContentAction,
               completed: @escaping (() -> Void)) {
        self.assetsSections = assetsSections
        self.leasingSections = leasingSections
        self.stakingSections = stakingSections
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completed()
        }
        
        switch animateType {
        case .none:
            break
            
        case .refresh(let animated):
            
            if animated {
                UIView.transition(with: scrolledTablesComponent,
                                  duration: Constants.animationDuration,
                                  options: [.transitionCrossDissolve],
                                  animations: {
                                      self.scrolledTablesComponent.reloadData()
                }, completion: nil)
            } else {
                scrolledTablesComponent.reloadData()
            }
            
        case .collapsed(let index):
            
            scrolledTablesComponent.reloadSectionWithCloseAnimation(section: index)
            
        case .expanded(let index):
            
            scrolledTablesComponent.reloadSectionWithOpenAnimation(section: index)
            
        default:
            break
        }
        CATransaction.commit()
    }
    
    var isAssetsSectionsHaveSearch: Bool {
        return assetsSections.first(where: { (section) -> Bool in
            switch section.kind {
            case .search:
                return true
            default:
                return false
            }
        }) != nil
    }
}

// MARK: Private

private extension WalletDisplayData {
    private func sections(by tableView: UITableView) -> [Section] {
                        
        if isDisplayInvesting {
            if tableView.tag == 0 {
                return stakingSections
            } else if tableView.tag == 1 {
                return leasingSections
            }
        } else {
            if tableView.tag == 0 {
                return assetsSections
            }
        }
                    
        return []
    }
    
    private func searchTapped(_ cell: UITableViewCell) {
        if let indexPath = scrolledTablesComponent.visibleTableView.indexPath(for: cell) {
            let rectInTableView = scrolledTablesComponent.visibleTableView.rectForRow(at: indexPath)
            let rectInSuperview = scrolledTablesComponent.visibleTableView.convert(rectInTableView, to: AppDelegate.shared().window)
            
            delegate?.showSearchVC(fromStartPosition: rectInSuperview.origin.y)
        }
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
            
            cell.sortTapped = { [weak self] in
                self?.delegate?.sortButtonTapped()
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
            
        case .historyCell(let type):
            let cell = tableView.dequeueAndRegisterCell() as WalletHistoryCell
            cell.update(with: type)
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
            
        case .stakingBalance(let balance):
            let cell = tableView.dequeueAndRegisterCell() as StakingBalanceCell
            cell.update(with: balance)
            cell.withdrawAction = { [weak self] in
                self?.delegate?.withdrawTapped()
            }
            cell.depositAction = { [weak self] in
                self?.delegate?.depositTapped()
            }
            cell.tradeAction = { [weak self] in
                self?.delegate?.tradeTapped()
            }
            cell.buyAction = { [weak self] in
                self?.delegate?.buyTapped()
            }
            return cell
            
        case .stakingLastPayoutsTitle:
            let cell = tableView.dequeueAndRegisterCell() as StakingLastPayoutsTitleCell
            cell.update(with: ())
            return cell
            
        case .stakingLastPayouts(let payouts):
            let cell = tableView.dequeueAndRegisterCell() as StakingLastPayoutsCell
            cell.update(with: payouts)
            return cell
            
        case .emptyHistoryPayouts:
            let cell = tableView.dequeueAndRegisterCell() as AssetEmptyHistoryCell
            cell.update(with: Localizable.Waves.Wallet.Stakingpayouts.youDontHavePayouts)
            return cell
            
        case .landing(let landing):
            let cell = tableView.dequeueAndRegisterCell() as StakingLandingCell
            cell.minHeight = scrolledTablesComponent.tableVisibleHeight
            cell.update(with: landing)
            cell.startStaking = { [weak self] in
                self?.delegate?.startStakingTapped()
            }
            
            cell.didSelectLinkWith = { [weak self] url in
                self?.delegate?.openStakingFaq(fromLanding: true)
            }
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

// MARK: UITableViewDelegate

extension WalletDisplayData: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let item = sections(by: tableView)[indexPath.section].items[indexPath.row]
        switch item {
        case .historySkeleton:
            let skeletonCell: WalletHistorySkeletonCell? = cell as? WalletHistorySkeletonCell
            skeletonCell?.startAnimation()
            
        case .assetSkeleton:
            let skeletonCell: WalletAssetSkeletonCell? = cell as? WalletAssetSkeletonCell
            skeletonCell?.startAnimation()
            
        case .balanceSkeleton:
            let skeletonCell: WalletLeasingBalanceSkeletonCell? = cell as? WalletLeasingBalanceSkeletonCell
            skeletonCell?.startAnimation()
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
        } else if let header = model.stakingHeader {
            let view = tableView.dequeueAndRegisterHeaderFooter() as StakingHeaderView
            view.update(with: header)
            view.howWorksAction = { [weak self] in
                self?.delegate?.openStakingFaq(fromLanding: false)
            }
            view.twAction = { [weak self] in
                
                let percent = (header.percent * 100).rounded() / 100
                let sharingText = Localizable.Waves.Staking
                    .sharingText("\(header.total.displayText)", "\(percent)").trimmingCharacters(in: .whitespacesAndNewlines)
                self?.delegate?.openTw(sharingText)
            }
            view.fbAction = { [weak self] in
                let percent = (header.percent * 100).rounded() / 100
                
                let sharingText = Localizable.Waves.Staking
                    .sharingText("\(header.total.displayText)", "\(percent)").trimmingCharacters(in: .whitespacesAndNewlines)
                self?.delegate?.openFb(sharingText)
            }
            view.vkAction = { [weak self] in
                let percent = (header.percent * 100).rounded() / 100
                
                let sharingText = Localizable.Waves.Staking
                    .sharingText("\(header.total.displayText)", "\(percent)").trimmingCharacters(in: .whitespacesAndNewlines)
                self?.delegate?.openVk(sharingText)
            }
            return view
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let model = sections(by: tableView)[section]
        
        if model.header != nil {
            return WalletHeaderView.viewHeight()
        } else if model.stakingHeader != nil {
            return StakingHeaderView.viewHeight()
        }
        
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return self.tableView(tableView, heightForHeaderInSection: section)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
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
            
        case .historyCell:
            return WalletHistoryCell.cellHeight()
            
        case .hidden:
            return CGFloat.leastNonzeroMagnitude
            
        case .quickNote:
            return WalletQuickNoteCell.cellHeight(with: tableView.frame.width)
            
        case .stakingBalance:
            return UITableView.automaticDimension
            
        case .stakingLastPayoutsTitle:
            return UITableView.automaticDimension
            
        case .stakingLastPayouts:
            return 76
            
        case .emptyHistoryPayouts:
            return AssetEmptyHistoryCell.cellHeight()
            
        case .landing:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView(tableView, heightForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.tableViewDidSelect(indexPath: indexPath)
    }
}

private extension WalletTypes.ViewModel.Section {
    var stakingHeader: WalletTypes.DTO.Staking.Profit? {
        switch kind {
        case .staking(let profit):
            return profit
        default:
            return nil
        }
    }
    
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
