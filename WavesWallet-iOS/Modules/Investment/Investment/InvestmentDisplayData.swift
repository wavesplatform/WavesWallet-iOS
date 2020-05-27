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

protocol InvestmentDisplayDataDelegate: AnyObject {
    func tableViewDidSelect(indexPath: IndexPath)
    func withdrawTapped()
    func depositTapped()
    func tradeTapped()
    func buyTapped()
    func openStakingFaq(fromLanding: Bool)
    func openTw(_ sharedText: String)
    func openFb(_ sharedText: String)
    func openVk(_ sharedText: String)
    func startStakingTapped()
}

final class InvestmentDisplayData: NSObject {
    private typealias Section = InvestmentSection

    private var leasingSections: [Section] = []
    private var stakingSections: [Section] = []

    private weak var scrolledTablesComponent: ScrolledContainerView!
    private let displays: [InvestmentDisplayState.Kind]

    weak var delegate: InvestmentDisplayDataDelegate?
    weak var balanceCellDelegate: InvestmentLeasingBalanceCellDelegate?

    let tapSection: PublishRelay<Int> = PublishRelay<Int>()
    var completedReload: (() -> Void)?
    
    init(scrolledTablesComponent: ScrolledContainerView,
         displays: [InvestmentDisplayState.Kind]) {
        self.displays = displays
        super.init()
        self.scrolledTablesComponent = scrolledTablesComponent
    }

    func apply(leasingSections: [InvestmentSection],
               stakingSections: [InvestmentSection],
               animateType: InvestmentDisplayState.ContentAction,
               completed: @escaping (() -> Void)) {
        self.leasingSections = leasingSections
        self.stakingSections = stakingSections

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completed()
        }

        switch animateType {
        case .none:
            break

        case let .refresh(animated):

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

        case let .collapsed(index):

            scrolledTablesComponent.reloadSectionWithCloseAnimation(section: index)

        case let .expanded(index):

            scrolledTablesComponent.reloadSectionWithOpenAnimation(section: index)

        default:
            break
        }
        CATransaction.commit()
    }

}

// MARK: Private

private extension InvestmentDisplayData {
    private func sections(by tableView: UITableView) -> [Section] {
        if tableView.tag == 0 {
            return stakingSections
        } else if tableView.tag == 1 {
            return leasingSections
        } else {
            return []
        }
    }
}

// MARK: UITableViewDelegate

extension InvestmentDisplayData: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = sections(by: tableView)[indexPath.section].items[indexPath.row]

        switch item {
        case .historySkeleton:
            return tableView.dequeueAndRegisterCell() as HistorySkeletonCell

        case .balanceSkeleton:
            return tableView.dequeueAndRegisterCell() as InvestmentLeasingBalanceSkeletonCell

        case let .balance(balance):
            let cell: InvestmentLeasingBalanceCell = tableView.dequeueAndRegisterCell()
            cell.update(with: balance)
            cell.delegate = balanceCellDelegate
            return cell

        case let .leasingTransaction(transaction):
            let cell: InvestmentLeasingCell = tableView.dequeueAndRegisterCell()
            cell.update(with: transaction)
            return cell

        case let .historyCell(type):
            let cell = tableView.dequeueAndRegisterCell() as InvestmentHistoryCell
            cell.update(with: type)
            return cell

        case .hidden:
            return tableView.dequeueAndRegisterCell() as EmptyCell

        case .quickNote:
            let cell = tableView.dequeueAndRegisterCell() as InvestmentLeasingQuickNoteCell
            cell.setupLocalization()
            return cell

        case let .stakingBalance(balance):
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
            return cell

        case let .stakingLastPayouts(payouts):
            let cell = tableView.dequeueAndRegisterCell() as StakingLastPayoutsCell
            cell.update(with: payouts)
            return cell

        case .emptyHistoryPayouts:
            let cell = tableView.dequeueAndRegisterCell() as AssetEmptyHistoryCell
            cell.update(with: Localizable.Waves.Wallet.Stakingpayouts.youDontHavePayouts)
            return cell

        case let .landing(landing):
            let cell = tableView.dequeueAndRegisterCell() as StakingLandingCell
            cell.minHeight = scrolledTablesComponent.tableVisibleHeight
            cell.update(with: landing)
            cell.startStaking = { [weak self] in
                self?.delegate?.startStakingTapped()
            }

            cell.didSelectLinkWith = { [weak self] _ in
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

extension InvestmentDisplayData: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let item = sections(by: tableView)[indexPath.section].items[indexPath.row]
        switch item {
        case .historySkeleton:
            let skeletonCell: HistorySkeletonCell? = cell as? HistorySkeletonCell
            skeletonCell?.startAnimation()
            
        case .balanceSkeleton:
            let skeletonCell: InvestmentLeasingBalanceSkeletonCell? = cell as? InvestmentLeasingBalanceSkeletonCell
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
            return HeaderWithArrowView.viewHeight()
        } else if model.stakingHeader != nil {
            return StakingHeaderView.viewHeight()
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
        case .historySkeleton:
            return HistorySkeletonCell.cellHeight()

        case .balanceSkeleton:
            return InvestmentLeasingBalanceSkeletonCell.cellHeight()

        case let .balance(balance):
            return InvestmentLeasingBalanceCell.viewHeight(model: balance, width: tableView.frame.size.width)

        case .leasingTransaction:
            return InvestmentLeasingCell.cellHeight()

        case .historyCell:
            return InvestmentHistoryCell.cellHeight()

        case .hidden:
            return CGFloat.leastNonzeroMagnitude

        case .quickNote:
            return InvestmentLeasingQuickNoteCell.cellHeight(with: tableView.frame.width)

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

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.tableViewDidSelect(indexPath: indexPath)
    }
}
