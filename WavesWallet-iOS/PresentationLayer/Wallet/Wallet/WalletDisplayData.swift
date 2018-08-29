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

protocol WalletDisplayDataDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView)

    func tableViewDidSelect(indexPath: IndexPath)
}

final class WalletDisplayData: NSObject {
    private typealias Section = WalletTypes.ViewModel.Section
    var delegate: WalletDisplayDataDelegate?
    let tapSection: PublishRelay<Int> = PublishRelay<Int>()
    var completedReload: (() -> Void)?

    private lazy var configureCell: ConfigureCell<Section> = { _, tableView, _, item in

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
            return cell

        case .leasingTransaction(let transaction):
            let cell: WalletLeasingCell = tableView.dequeueAndRegisterCell()
            cell.update(with: transaction)
            return cell

        case .allHistory:
            return tableView.dequeueAndRegisterCell() as WalletHistoryCell

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

    private lazy var dataSource = RxTableViewAnimatedDataSource(configureCell: configureCell)

    private var disposeBag: DisposeBag = DisposeBag()

    func bind(tableView: UITableView,
              event: Driver<[WalletTypes.ViewModel.Section]>) {

        dataSource.completedReload = { [weak self] in
            self?.completedReload?()
        }

        tableView
            .rx
            .setDelegate(self)
            .disposed(by: disposeBag)

        event
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

    func collapsed(tableView: UITableView,
                   event: Driver<(sections: [WalletTypes.ViewModel.Section], index: Int)>) {
        dataSource.tableView(tableView, reloadSection: event.map { .init(sections: $0, index: $1) })
    }

    func expanded(tableView: UITableView,
                  event: Driver<(sections: [WalletTypes.ViewModel.Section], index: Int)>) {
        dataSource.tableView(tableView, reloadSection: event.map { .init(sections: $0, index: $1) })
    }
}

// MARK: UITableViewDelegate

extension WalletDisplayData: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let item = dataSource[indexPath]
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
        let model = dataSource[section]

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
        let model = dataSource[section]
        if model.header != nil {
            return WalletHeaderView.viewHeight()
        }

        return CGFloat.minValue
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
        let row = dataSource[indexPath]

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
