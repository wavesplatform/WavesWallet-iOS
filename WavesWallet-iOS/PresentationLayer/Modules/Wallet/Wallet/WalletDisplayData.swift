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

protocol WalletDisplayDataDelegate: AnyObject {
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    func tableViewDidSelect(indexPath: IndexPath)
}

final class WalletDisplayData: NSObject {
    private typealias Section = WalletTypes.ViewModel.Section

    private var sections: [Section] = []
    private weak var tableView: UITableView!

    weak var delegate: WalletDisplayDataDelegate?
    weak var balanceCellDelegate: WalletLeasingBalanceCellDelegate?

    let tapSection: PublishRelay<Int> = PublishRelay<Int>()
    var completedReload: (() -> Void)?

    init(tableView: UITableView) {
        super.init()
        self.tableView = tableView
        tableView.delegate = self
        tableView.dataSource = self
    }

    func apply(sections: [WalletTypes.ViewModel.Section], animateType: WalletTypes.DisplayState.AnimateType, completed: @escaping (() -> Void)) {
        self.sections = sections

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completed()
        }
        switch animateType {
        case .refresh:

            UIView.animate(withDuration: 0.24, delay: 0, options: [.transitionCrossDissolve], animations: {
                self.tableView.reloadData()
            }, completion: nil)

        case .collapsed(let index):
            tableView.beginUpdates()
            tableView.reloadSections([index], animationStyle: .fade)
            tableView.endUpdates()

        case .expanded(let index):
            tableView.beginUpdates()
            tableView.reloadSections([index], animationStyle: .fade)
            tableView.scrollToRow(at: IndexPath(row: 0, section: index), at: .middle, animated: true)
            tableView.endUpdates()
        }
        CATransaction.commit()
    }
}

// MARK: UITableViewDelegate
extension WalletDisplayData: UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let item = sections[indexPath.section].items[indexPath.row]
    
        switch item {
        case .historySkeleton:
            return tableView.dequeueCell() as WalletHistorySkeletonCell

        case .balanceSkeleton:
            return tableView.dequeueCell() as WalletLeasingBalanceSkeletonCell

        case .assetSkeleton:
            return tableView.dequeueCell() as WalletAssetSkeletonCell

        case .balance(let balance):
            let cell: WalletLeasingBalanceCell = tableView.dequeueCell()
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
            let cell: WalletTableAssetsCell = tableView.dequeueCell()
            cell.update(with: model)
            return cell

        case .quickNote:
            return tableView.dequeueCell() as WalletQuickNoteCell
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
}

extension WalletDisplayData: UITableViewDelegate {

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        let item = sections[indexPath.section].items[indexPath.row]
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
        let model = sections[section]

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
        let model = sections[section]

        if model.header == nil {
            return CGFloat.minValue
        } else {
            return WalletHeaderView.viewHeight()
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return self.tableView(tableView, heightForHeaderInSection: section)
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.minValue
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.minValue
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = sections[indexPath.section].items[indexPath.row]

        switch row {
        case .historySkeleton:
            return WalletHistorySkeletonCell.cellHeight()

        case .balanceSkeleton:
            return WalletLeasingBalanceSkeletonCell.cellHeight()

        case .asset:
            return WalletTableAssetsCell.cellHeight()

        case .assetSkeleton:
            return WalletAssetSkeletonCell.cellHeight()

        case .balance:
            return WalletLeasingBalanceCell.cellHeight()

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

extension WalletDisplayData: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll(scrollView)
    }
}

fileprivate extension WalletTypes.ViewModel.Section {

    var header: String? {

        switch kind {
        case .info:
            return Localizable.Waves.Wallet.Section.quickNote

        case .transactions:
            return Localizable.Waves.Wallet.Section.activeNow(items.count)

        case .spam(let count):
            return Localizable.Waves.Wallet.Section.spamAssets(count)

        case .hidden(let count):
            return Localizable.Waves.Wallet.Section.hiddenAssets(count)

        default:
            return nil
        }
    }
}
