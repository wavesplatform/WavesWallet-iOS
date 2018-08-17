//
//  HistoryTypes+ViewModels.swift
//  WavesWallet-iOS
//
//  Created by Mac on 06/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension HistoryTypes.ViewModel {
    struct Section: Hashable {
        var items: [Row]
        var header: String?
        
        init(items: [Row], header: String? = nil) {
            self.items = items
            self.header = header
        }
    }
    
    enum Row: Hashable {
        case transaction(HistoryTypes.DTO.Transaction)
        case transactionSkeleton
    }
}


extension HistoryTypes.ViewModel.Section {
    static func filter(from transactions: [HistoryTypes.DTO.Transaction], filter: HistoryTypes.Filter) -> [HistoryTypes.ViewModel.Section] {
        let filteredTransactions = transactions
            .filter { filter.kinds.contains($0.kind) }
        
        return sections(from: filteredTransactions)
    }
    
    static func map(from transactions: [HistoryTypes.DTO.Transaction]) -> [HistoryTypes.ViewModel.Section] {
        return sections(from: transactions)
    }
    
    static func sections(from transactions: [HistoryTypes.DTO.Transaction]) -> [HistoryTypes.ViewModel.Section] {
        
        let transactions = transactions
            .sorted(by: { (transaction1, transaction2) -> Bool in
                return transaction1.date.timeIntervalSince1970 > transaction2.date.timeIntervalSince1970
            })
        
        var sections: [NSMutableArray] = []
        var lastSection: NSMutableArray = NSMutableArray()
        var previousDay: Int? = 0
        var previousMonth: Int? = 0
        var previousYear: Int? = 0
        
        for transaction in transactions {
            let calendar = NSCalendar.current
            
            let components = calendar.dateComponents([.day, .month, .year], from: transaction.date as Date)
            
            let year = components.year
            let month = components.month
            let day = components.day
            
            if day != previousDay || month != previousMonth || year != previousYear {
                lastSection = NSMutableArray()
                sections.append(lastSection)
            }
            
            lastSection.add(transaction)
            
            previousDay = day
            previousMonth = month
            previousYear = year
        }
        
        let items = sections.map { (arr) -> [HistoryTypes.ViewModel.Row] in
            return arr.map({ HistoryTypes.ViewModel.Row.transaction($0 as! HistoryTypes.DTO.Transaction) })
        }
        
        let generalSections = items.map { HistoryTypes.ViewModel.Section(items: $0) }
        
        return generalSections
    }
}
