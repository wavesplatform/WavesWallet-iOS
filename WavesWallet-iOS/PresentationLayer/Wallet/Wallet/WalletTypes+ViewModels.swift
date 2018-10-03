//
//  WalletTypes+ViewModels.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 16/07/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
//import RxDataSources

// MARK: ViewModel for UITableView

extension WalletTypes.ViewModel {
    enum Row {
        case hidden
        case asset(WalletTypes.DTO.Asset)
        case assetSkeleton
        case balanceSkeleton
        case historySkeleton
        case balance(WalletTypes.DTO.Leasing.Balance)
        case leasingTransaction(DomainLayer.DTO.SmartTransaction)
        case allHistory
        case quickNote
    }

    struct Section {

        enum Kind {
            case skeleton
            case balance
            case transactions
            case info
            case general
            case spam
            case hidden
        }

        var kind: Kind
        var header: String?
        var items: [Row]
        var isExpanded: Bool
    }
}

extension WalletTypes.ViewModel.Row {

        var asset: WalletTypes.DTO.Asset? {
            switch self {
            case .asset(let asset):
                return asset
            default:
                return nil
            }
        }

    var leasingTransaction: DomainLayer.DTO.SmartTransaction? {
        switch self {
        case .leasingTransaction(let tx):
            return tx
        default:
            return nil
        }
    }
}
extension WalletTypes.ViewModel.Section {

    static func map(from assets: [WalletTypes.DTO.Asset]) -> [WalletTypes.ViewModel.Section] {
        let generalItems = assets
            .filter { $0.isSpam != true && $0.isHidden != true }
            .sorted(by: { (asset1, asset2) -> Bool in

                if asset1.isWaves == true {
                    return true
                }

                if asset1.isFavorite == true && asset2.isFavorite == false {
                    return true
                } else if asset1.isFavorite == false && asset2.isFavorite == true {
                    return false
                }

                return asset1.sortLevel < asset2.sortLevel
            })
            .map { WalletTypes.ViewModel.Row.asset($0) }
        let generalSection: WalletTypes.ViewModel.Section = .init(kind: .general,
                                                                  header: nil,
                                                                  items: generalItems,
                                                                  isExpanded: true)
        let hiddenItems = assets
            .filter { $0.isHidden == true }
            .sorted(by: { (asset1, asset2) -> Bool in
                asset1.sortLevel < asset2.sortLevel
            })
            .map { WalletTypes.ViewModel.Row.asset($0) }

        let hiddenSection: WalletTypes.ViewModel.Section = .init(kind: .hidden,
                                                                 header: Localizable.Wallet.Section.hiddenAssets(hiddenItems.count),
                                                                 items: hiddenItems,
                                                                 isExpanded: false)
        let spamItems = assets
            .filter { $0.isSpam == true }
            .sorted(by: { (asset1, asset2) -> Bool in
                asset1.sortLevel < asset2.sortLevel
            })
            .map { WalletTypes.ViewModel.Row.asset($0) }

        let spamSection: WalletTypes.ViewModel.Section = .init(kind: .spam,
                                                               header: Localizable.Wallet.Section.spamAssets(spamItems.count),
                                                               items: spamItems,
                                                               isExpanded: false)
        return [generalSection,
                hiddenSection,
                spamSection]
    }

    static func map(from leasing: WalletTypes.DTO.Leasing) -> [WalletTypes.ViewModel.Section] {
        var sections: [WalletTypes.ViewModel.Section] = []

        let balanceRow = WalletTypes.ViewModel.Row.balance(leasing.balance)
        let historyRow = WalletTypes.ViewModel.Row.allHistory
        let mainSection: WalletTypes.ViewModel.Section = .init(kind: .balance,
                                                               header: nil,
                                                               items: [balanceRow, historyRow],
                                                               isExpanded: true)
        sections.append(mainSection)
        if leasing.transactions.count > 0 {
            let rows = leasing
                .transactions
                .map { WalletTypes.ViewModel.Row.leasingTransaction($0) }

            let activeTransactionSection: WalletTypes
                .ViewModel
                .Section = .init(kind: .transactions,
                                 header: Localizable.Wallet.Section.activeNow(rows.count),
                                 items: rows,
                                 isExpanded: true)
            sections.append(activeTransactionSection)
        }

        let noteSection: WalletTypes.ViewModel.Section = .init(kind: .info,
                                                               header: Localizable.Wallet.Section.quickNote,
                                                               items: [.quickNote],
                                                               isExpanded: true)
        sections.append(noteSection)
        return sections
    }
}

