//
//  WalletTypes+ViewModels.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 16/07/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxDataSources

// MARK: ViewModel for UITableView

extension WalletTypes.ViewModel {
    enum Row: Hashable {
        case hidden
        case asset(WalletTypes.DTO.Asset)
        case assetSkeleton
        case balanceSkeleton
        case historySkeleton
        case balance(WalletTypes.DTO.Leasing.Balance)
        case leasingTransaction(WalletTypes.DTO.Leasing.Transaction)
        case allHistory
        case quickNote
    }

    struct Section: Hashable {
        enum Kind {
            case mainAssets
            case spamAssets
            case hiddenAssets
            case mainLeasing
            case activeTransaction
            case quickNote
        }

        struct Data {
            var type: Kind
            var isExpanded: Bool
        }

        var header: String?
        var items: [Row]
        var isExpanded: Bool
    }
}

extension WalletTypes.ViewModel.Section: SectionModelType {
    init(original: WalletTypes.ViewModel.Section, items: [WalletTypes.ViewModel.Row]) {
        self = original
        self.items = items
    }
}

extension WalletTypes.ViewModel.Section {
    static func map(from assets: [WalletTypes.DTO.Asset]) -> [WalletTypes.ViewModel.Section] {
        let generalItems = assets
            .filter { $0.kind == .general }
            .sorted(by: { (asset1, asset2) -> Bool in
                asset1.sortLevel < asset2.sortLevel
            })
            .map { WalletTypes.ViewModel.Row.asset($0) }
        let generalSection: WalletTypes.ViewModel.Section = .init(header: nil,
                                                                  items: generalItems,
                                                                  isExpanded: true)
        let hiddenItems = assets
            .filter { $0.kind == .hidden }
            .sorted(by: { (asset1, asset2) -> Bool in
                asset1.sortLevel < asset2.sortLevel
            })
            .map { WalletTypes.ViewModel.Row.asset($0) }

        let hiddenSection: WalletTypes.ViewModel.Section = .init(header: "Hidden",
                                                                 items: hiddenItems,
                                                                 isExpanded: true)
        let spamItems = assets
            .filter { $0.kind == .spam }
            .sorted(by: { (asset1, asset2) -> Bool in
                asset1.sortLevel < asset2.sortLevel
            })
            .map { WalletTypes.ViewModel.Row.asset($0) }

        let spamSection: WalletTypes.ViewModel.Section = .init(header: "Spam",
                                                               items: spamItems,
                                                               isExpanded: true)
        return [generalSection,
                hiddenSection,
                spamSection]
    }

    static func map(from leasing: WalletTypes.DTO.Leasing) -> [WalletTypes.ViewModel.Section] {
        var sections: [WalletTypes.ViewModel.Section] = []

        let balanceRow = WalletTypes.ViewModel.Row.balance(leasing.balance)
        let historyRow = WalletTypes.ViewModel.Row.allHistory
        let mainSection: WalletTypes.ViewModel.Section = .init(header: nil,
                                                               items: [balanceRow, historyRow],
                                                               isExpanded: true)
        sections.append(mainSection)
        if leasing.transactions.count > 0 {
            let rows = leasing.transactions.map { WalletTypes.ViewModel.Row.leasingTransaction($0) }
            let activeTransactionSection: WalletTypes.ViewModel.Section = .init(header: "Active",
                                                                                items: rows,
                                                                                isExpanded: true)
            sections.append(activeTransactionSection)
        }

        let noteSection: WalletTypes.ViewModel.Section = .init(header: "Note",
                                                               items: [.quickNote],
                                                               isExpanded: true)
        sections.append(noteSection)
        return sections
    }
}
