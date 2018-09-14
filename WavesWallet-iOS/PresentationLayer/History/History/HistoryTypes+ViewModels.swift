//
//  HistoryTypes+ViewModels.swift
//  WavesWallet-iOS
//
//  Created by Mac on 06/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension HistoryTypes.ViewModel {
    struct Section {
        var items: [Row]
        var header: String?
        
        init(items: [Row], header: String? = nil) {
            self.items = items
            self.header = header
        }
    }
    
    enum Row {
        case transaction(DomainLayer.DTO.SmartTransaction)
        case transactionSkeleton
    }
}


extension HistoryTypes.ViewModel.Section {
    static func filter(from transactions: [DomainLayer.DTO.SmartTransaction], filter: HistoryTypes.Filter) -> [HistoryTypes.ViewModel.Section] {
        let filteredTransactions = transactions
            .filter { filter.isNeedTransaction(where: $0) }
        
        return sections(from: filteredTransactions)
    }
    
    static func map(from transactions: [DomainLayer.DTO.SmartTransaction]) -> [HistoryTypes.ViewModel.Section] {
        return sections(from: transactions)
    }
    
    static func sections(from transactions: [DomainLayer.DTO.SmartTransaction]) -> [HistoryTypes.ViewModel.Section] {

        let calendar = NSCalendar.current
        let sections = transactions.reduce(into: [Date:  [DomainLayer.DTO.SmartTransaction]]()) { result, tx in

            let components = calendar.dateComponents([.day, .month, .year], from: tx.timestamp)
            let date = calendar.date(from: components) ?? Date()
            var list = result[date] ?? []
            list.append(tx)
            result[date] = list
        }

        let sortedKeys = Array(sections.keys).sorted(by: { $0 > $1 })

        let formatter = DateFormatter.sharedFormatter
        //TODO: Constants
        formatter.dateFormat = "MMM dd, yyyy"

        return sortedKeys.map { key -> HistoryTypes.ViewModel.Section? in
            guard let section = sections[key] else { return nil }
            let rows = section.map { HistoryTypes.ViewModel.Row.transaction($0) }
            return HistoryTypes.ViewModel.Section.init(items: rows,
                                                       header: formatter.string(from: key))
        }
        .compactMap { $0 }
    }
}
