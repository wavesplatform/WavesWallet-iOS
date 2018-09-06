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
        case transaction(GeneralTypes.DTO.Transaction)
        case transactionSkeleton
    }
}


extension HistoryTypes.ViewModel.Section {
    static func filter(from transactions: [GeneralTypes.DTO.Transaction], filter: HistoryTypes.Filter) -> [HistoryTypes.ViewModel.Section] {
        let filteredTransactions = transactions
            .filter { filter.isNeedTransaction(where: $0) }
        
        return sections(from: filteredTransactions)
    }
    
    static func map(from transactions: [GeneralTypes.DTO.Transaction]) -> [HistoryTypes.ViewModel.Section] {
        return sections(from: transactions)
    }
    
    static func sections(from transactions: [GeneralTypes.DTO.Transaction]) -> [HistoryTypes.ViewModel.Section] {
                
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
            return arr.map({ HistoryTypes.ViewModel.Row.transaction($0 as! GeneralTypes.DTO.Transaction) })
        }
        
        let generalSections = items.map { HistoryTypes.ViewModel.Section(items: $0) }
        
        return generalSections
    }
}
