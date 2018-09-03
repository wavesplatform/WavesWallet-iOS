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
    struct General {
        let kind: TransactionHistoryTypes.DTO.Transaction.Kind
        let value: String
        let currencyConversion: String
        let tag: String
    }
    
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
        enum ButtonType {
            case resend
            case cancelLeasing
        }
        
        let type: ButtonType
    }
    
    enum Row {
        case general(General)
        case recipient(Recipient)
        case comment(Comment)
        case keyValue(KeyValue)
        case keysValues([KeyValue])
        case status(Status)
        case resendButton(ResendButton)
    }
    
    struct Section {
        var items: [Row]
    }
}

extension TransactionHistoryTypes.ViewModel.Section {
    
    static func map(from transaction: TransactionHistoryTypes.DTO.Transaction) -> [TransactionHistoryTypes.ViewModel.Section] {
        
        var rows: [TransactionHistoryTypes.ViewModel.Row] = []
        
        rows.append(.general(.init(kind: transaction.kind, value: "+000000000.00000000", currencyConversion: "= 00 000 00 US Dollar", tag: "WAVES")))
        rows.append(.recipient(.init(name: "Mr. Brock", address: "96AFUzFKebbwmJulY6evx9GrfYBkmn8LcUL0")))
        rows.append(.comment(.init(text: "This is the comment we all wanted ant its very looooooong")))
        rows.append(.keyValue(.init(title: "Fee", value: "0.0000001 Waves")))

        rows.append(.keysValues(
            [
                .init(title: "Confirmations", value: "09090"),
                .init(title:"Block", value: "106060")
            ])
        )
        rows.append(.status(.init(timestamp: "12.04.2018", status: .activeNow)))
        rows.append(.resendButton(.init(type: .resend)))
        
        let generalSection = TransactionHistoryTypes.ViewModel.Section(items: rows)
        
        return [generalSection]
        
    }
    
}
