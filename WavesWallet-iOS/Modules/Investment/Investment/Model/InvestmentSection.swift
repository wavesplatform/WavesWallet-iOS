//
//  InvestmentSection.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 18.05.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation

struct InvestmentSection {
    enum Kind {
        case search
        case skeleton
        case balance
        case transactions(count: Int)
        case info
        case general
        case spam(count: Int)
        case hidden(count: Int)
        case staking(InvestmentStakingVM.Profit)
        case landing
    }

    var kind: Kind
    var items: [InvestmentRow]
    var isExpanded: Bool
}

extension InvestmentSection {

    static func map(from leasing: InvestmentLeasingVM) -> [InvestmentSection] {
        var sections: [InvestmentSection] = []

        let balanceRow = InvestmentRow.balance(leasing.balance)
        let historyRow = InvestmentRow.historyCell(.leasing)
        let mainSection: InvestmentSection = .init(kind: .balance,
                                                               items: [balanceRow, historyRow],
                                                               isExpanded: true)
        sections.append(mainSection)
        if !leasing.transactions.isEmpty {
            let rows = leasing
                .transactions
                .map { InvestmentRow.leasingTransaction($0) }

            let activeTransactionSection: InvestmentSection = .init(kind: .transactions(count: leasing.transactions.count),
                                 items: rows,
                                 isExpanded: true)
            sections.append(activeTransactionSection)
        }

        let noteSection: InvestmentSection = .init(kind: .info,
                                                               items: [.quickNote],
                                                               isExpanded: false)
        sections.append(noteSection)
        return sections
    }

    static func map(from staking: InvestmentStakingVM, hasSkingLanding: Bool) -> [InvestmentSection] {
        var rows: [InvestmentRow] = []

        if let landing = staking.landing, hasSkingLanding == false {
            rows.append(.landing(landing))
            return [.init(kind: .landing, items: rows, isExpanded: true)]
        }

        rows.append(.stakingBalance(staking.balance))
        rows.append(.stakingLastPayoutsTitle)

        let lastPayouts = prepareTransactionViewModels(massTransfersTrait: staking.lastPayouts)

        if !lastPayouts.isEmpty {
            rows.append(.stakingLastPayouts(lastPayouts))
            rows.append(.historyCell(.staking))
        } else {
            rows.append(.emptyHistoryPayouts)
        }

        return [.init(kind: .staking(staking.profit), items: rows, isExpanded: true)]
    }

    private static func prepareTransactionViewModels(massTransfersTrait: PayoutsHistoryState.MassTransferTrait)
        -> [PayoutTransactionVM] {
        massTransfersTrait
            .massTransferTransactions
            .transactions
            .map { transaction -> PayoutTransactionVM in
                let iconAsset = massTransfersTrait.assetLogo
                let amount = transaction.transfers
                    .filter { $0.recipient == massTransfersTrait.walletAddress }
                    .reduce(0) { $0 + $1.amount }

                let money = Money(value: Decimal(amount), massTransfersTrait.precision ?? 0)
                let currency = DomainLayer.DTO.Balance.Currency(title: "", ticker: massTransfersTrait.assetTicker)

                let balance = DomainLayer.DTO.Balance(currency: currency, money: money)
                let transactionValue = BalanceLabel.Model(balance: balance, sign: .plus, style: .medium)

                let dateFormatter = DateFormatter.uiSharedFormatter(key: "PayoutsHistorySystem",
                                                                    style: .pretty(transaction.timestamp))

                let dateText = dateFormatter.string(from: transaction.timestamp)

                return PayoutTransactionVM(title: Localizable.Waves.Payoutshistory.profit,
                                           iconAsset: iconAsset,
                                           transactionValue: transactionValue,
                                           dateText: dateText)
            }
    }
}

extension InvestmentSection {
    var stakingHeader: InvestmentStakingVM.Profit? {
        switch kind {
        case let .staking(profit):
            return profit
        default:
            return nil
        }
    }

    var header: String? {
        switch kind {
        case .info:
            return Localizable.Waves.Wallet.Section.quickNote

        case let .transactions(count):
            return Localizable.Waves.Wallet.Section.activeNow(count)

        case let .spam(count):
            return Localizable.Waves.Wallet.Section.spamAssets(count)

        case let .hidden(count):
            return Localizable.Waves.Wallet.Section.hiddenAssets(count)

        default:
            return nil
        }
    }
}
