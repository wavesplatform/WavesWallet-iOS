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
import UITools

private enum Constants {
    static let animationDuration: TimeInterval = 0.34
}

protocol WalletDisplayDataDelegate: AnyObject {
    func tableViewDidSelect(indexPath: IndexPath)
    func showSearchVC(fromStartPosition: CGFloat)
    func sortButtonTapped()
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate _: Bool)
    func scrollViewDidScroll(_ scrollView: UIScrollView)
}

final class WalletDisplayData: NSObject {
    
    weak var tableView: UITableView!
    private var assetsSections: [Section] = []
    
    private let displays: [WalletDisplayState.Kind]
    
    weak var delegate: WalletDisplayDataDelegate?

    let tapSection: PublishRelay<Int> = PublishRelay<Int>()
    var completedReload: (() -> Void)?

    init(tableView: UITableView, displays: [WalletDisplayState.Kind]) {
        self.displays = displays
        super.init()
        self.tableView = tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = UITableView.automaticDimension
    }

    func apply(assetsSections: [WalletSectionVM],
               animateType: WalletDisplayState.ContentAction,
               completed: @escaping (() -> Void)) {
        self.assetsSections = assetsSections

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completed()
        }

        switch animateType {
        case .none:
            break

        case let .refresh(animated):

            if animated {
                UIView.transition(with: tableView,
                                  duration: Constants.animationDuration,
                                  options: [.transitionCrossDissolve],
                                  animations: {
                                      self.tableView.reloadData()
                }, completion: nil)
            } else {
                tableView.reloadData()
            }

        case let .collapsed(index):

            tableView.beginUpdates()
            tableView.reloadSections([index], with: .fade)
            tableView.endUpdates()

        case let .expanded(index):

            tableView.beginUpdates()
            tableView.reloadSections([index], with: .fade)
            tableView.endUpdates()
            
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
    private func sections(by _: UITableView) -> [Section] {
        return assetsSections
    }

    private func searchTapped(_ cell: UITableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let rectInTableView = tableView.rectForRow(at: indexPath)
            let rectInSuperview = tableView
                .convert(rectInTableView, to: AppDelegate.shared().window)

            delegate?.showSearchVC(fromStartPosition: rectInSuperview.origin.y)
        }
    }
}


// MARK: UIScrollViewDelegate

extension WalletDisplayData: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.delegate?.scrollViewDidEndDecelerating(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate: Bool) {
        self.delegate?.scrollViewDidEndDragging(scrollView, willDecelerate: willDecelerate)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.delegate?.scrollViewDidScroll(scrollView)
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

        case .assetSkeleton:
            return tableView.dequeueAndRegisterCell() as AssetSkeletonCell

        case .hidden:
            return tableView.dequeueAndRegisterCell() as EmptyCell

        case let .asset(model):
            let cell: WalletTableAssetsCell = tableView.dequeueAndRegisterCell()
            cell.update(with: model)
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
        case .assetSkeleton:
            let skeletonCell: AssetSkeletonCell? = cell as? AssetSkeletonCell
            skeletonCell?.startAnimation()

        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let model = sections(by: tableView)[section]

        if let header = model.header {
            let view: HeaderWithArrowView = tableView.dequeueAndRegisterHeaderFooter()
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

        if model.header != nil {
            return HeaderWithArrowView.viewHeight()
        }

        return CGFloat.leastNonzeroMagnitude
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return self.tableView(tableView, heightForHeaderInSection: section)
    }

    func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? {
        return UIView()
    }

    func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }

    func tableView(_: UITableView, estimatedHeightForFooterInSection _: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let items = sections(by: tableView)[indexPath.section].items
        let row = items[indexPath.row]

        switch row {
        case .search:
            return WalletSearchTableViewCell.viewHeight()

        case .asset:
            return WalletTableAssetsCell.cellHeight()

        case .assetSkeleton:
            return AssetSkeletonCell.cellHeight()

        case .hidden:
            return CGFloat.leastNonzeroMagnitude
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView(tableView, heightForRowAt: indexPath)
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.tableViewDidSelect(indexPath: indexPath)
    }
}

private extension WalletSectionVM {
    var header: String? {
        switch kind {
        case .info:
            return Localizable.Waves.Wallet.Section.quickNote

        case let .spam(count):
            return Localizable.Waves.Wallet.Section.spamAssets(count)

        case let .hidden(count):
            return Localizable.Waves.Wallet.Section.hiddenAssets(count)

        default:
            return nil
        }
    }
}
