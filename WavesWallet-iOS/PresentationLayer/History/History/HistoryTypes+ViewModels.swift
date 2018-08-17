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
        
        let generalItems = transactions
            .filter { filter.kinds.contains($0.kind) }
            .sorted(by: { (transaction1, transaction2) -> Bool in
                return transaction1.date.timeIntervalSince1970 > transaction2.date.timeIntervalSince1970
            })
            .map { HistoryTypes.ViewModel.Row.transaction($0) }
        
        let generalSection: HistoryTypes.ViewModel.Section = .init(items: generalItems)
        
        return [generalSection, generalSection]
        
    }
    
    static func map(from transactions: [HistoryTypes.DTO.Transaction]) -> [HistoryTypes.ViewModel.Section] {
        let generalItems = transactions
            .sorted(by: { (transaction1, transaction2) -> Bool in
                return transaction1.date.timeIntervalSince1970 > transaction2.date.timeIntervalSince1970
            })
            .map { HistoryTypes.ViewModel.Row.transaction($0) }
        
        let generalSection: HistoryTypes.ViewModel.Section = .init(items: generalItems)

        return [generalSection, generalSection]
    }
}
