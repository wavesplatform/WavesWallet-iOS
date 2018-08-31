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
    
    struct Comment: Hashable {
        let text: String
    }
    
    struct Status: Hashable {
        let timestamp: String
        let status: TransactionHistoryTypes.DTO.Transaction.Status
    }
    
    struct ResendButton: Hashable {
        let title: String
    }
    
    enum Row: Hashable {
        case recipient(Recipient)
        case comment(Comment)
        case keyValue(KeyValue)
        case keysValues([KeyValue])
        case status(Status)
        case resendButton(ResendButton)
    }
    
    struct Section: Hashable {
        var items: [Row]
    }
}

extension TransactionHistoryTypes.ViewModel.Section {
    
    static func map(from transaction: TransactionHistoryTypes.DTO.Transaction) -> [TransactionHistoryTypes.ViewModel.Section] {
        
        var rows: [TransactionHistoryTypes.ViewModel.Row] = []
        
        rows.append(.recipient(.init(name: nil, address: "sdfokpok3rp34kk54")))
        rows.append(.comment(.init(text: "This is the comment we ll wanted")))
        rows.append(.keyValue(.init(title: "Fee", value: "0.001 Waves")))

        rows.append(.keysValues(
            [
                .init(title: "Confirmations", value: "09090"),
                .init(title:"Block", value: "106060")
            ])
        )
        rows.append(.status(.init(timestamp: "Year 2002", status: .activeNow)))
        rows.append(.resendButton(.init(title: "Cancel leasing")))
        
        let generalSection = TransactionHistoryTypes.ViewModel.Section(items: rows)
        
        return [generalSection]
        
    }
    
}
