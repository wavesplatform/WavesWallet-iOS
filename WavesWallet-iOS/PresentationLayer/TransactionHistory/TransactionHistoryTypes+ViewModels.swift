//
//  TransactionHistoryTypes+ViewModels.swift
//  WavesWallet-iOS
//
//  Created by Mac on 24/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxDataSources

extension TransactionHistoryTypes.ViewModel {
    struct Recipient: Hashable {
        let name: String?
        let address: String
    }
    
    struct KeyValue: Hashable {
        let title: String
        let value: String
    }
    
    struct Data: Hashable {
        let data: String
    }
    
    enum Row: Hashable {
        case keyValue(KeyValue)
        case keysValues([KeyValue])
        case recipient(Recipient)
        case comment(String)
        case resendButton
    }
    
    struct Section: Hashable {
        var items: [Row]
    }
}

extension TransactionHistoryTypes.ViewModel.Section {
    
    static func map(from transaction: TransactionHistoryTypes.DTO.Transaction) -> [TransactionHistoryTypes.ViewModel.Section] {
        
        var rows: [TransactionHistoryTypes.ViewModel.Row] = []
        
        rows.append(.recipient(.init(name: nil, address: "sdfokpok3rp34kk54")))
        rows.append(.keyValue(.init(title: "Fee", value: "0.001 Waves")))
        rows.append(.keysValues(
            [
                .init(title: "Confirmations", value: "09090"),
                .init(title:"Block", value: "106060")
            ])
        )
        rows.append(.keyValue(.init(title: "Timestamp", value: "DD.MM.YYYY at 00:00")))
        
        let generalSection = TransactionHistoryTypes.ViewModel.Section(items: rows)
        
        return [generalSection]
        
    }
    
}
