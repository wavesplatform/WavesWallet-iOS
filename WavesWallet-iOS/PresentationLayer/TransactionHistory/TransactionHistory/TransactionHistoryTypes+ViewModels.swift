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
        let kind: DomainLayer.DTO.SmartTransaction.Kind
        let balance: Balance
        let currencyConversion: String?
    }
    
    struct Recipient {
        let kind: DomainLayer.DTO.SmartTransaction.Kind
        let name: String?
        let address: String
    }
    
    struct KeyValue: Hashable {
        let title: String
        let value: String
        let subvalue: String?
        
        init(title: String, value: String, subvalue: String? = nil) {
            self.title = title
            self.value = value
            self.subvalue = subvalue
        }
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
    
    static func map(from transaction: DomainLayer.DTO.SmartTransaction) -> [TransactionHistoryTypes.ViewModel.Section] {
        
        var rows: [TransactionHistoryTypes.ViewModel.Row] = []
        
        var kindRows: [TransactionHistoryTypes.ViewModel.Row] = []
        
        switch transaction.kind {
        case .receive(let model):
            break
//            kindRows.append(.recipient(.init(kind: transaction.kind, name: model.from.name, address: model.from.address)))
            
        case .sent(let model):
            break
//            kindRows.append(.recipient(.init(kind: transaction.kind, name: model.to.name, address: model.to.address)))
            
        case .startedLeasing(let model):
            break
//            kindRows.append(.recipient(.init(kind: transaction.kind, name: model.to.name, address: model.to.address)))
            
        case .exchange(let model):
            break
//            kindRows.append(.keyValue(.init(title: model.exchangeCurrency + " Price", value: model.exchangeBalance.formattedText())))
            
        case .selfTransfer(let model):
            
            break
            
        case .tokenGeneration(let model):
            break
//            kindRows.append(.keyValue(.init(title: "ID", value: model.id, subvalue: model.reissuable ? "Reissuable" : "Not Reissuable")))
            
        case .tokenReissue(let model):
            break
//            kindRows.append(.keyValue(.init(title: "ID", value: model.id, subvalue: model.reissuable ? "Reissuable" : "Not Reissuable")))
            
        case .tokenBurn(let model):
            break
//            kindRows.append(.keyValue(.init(title: "ID", value: model.id)))
            
        case .createdAlias(let model):
            break
            
        case .canceledLeasing(let model):
        break
//            kindRows.append(.recipient(.init(kind: transaction.kind, name: model.from.name, address: model.from.address)))
            
        case .incomingLeasing(let model):
            break
//            kindRows.append(.recipient(.init(kind: transaction.kind, name: model.from.name, address: model.from.address)))
            
        case .massSent(let model):
            break
//            for to in model.to {
//                 kindRows.append(.recipient(.init(kind: transaction.kind, name: to.name, address: to.address)))
//            }
            
        case .massReceived(let model):
            break
//            for from in model.from {
//                kindRows.append(.recipient(.init(kind: transaction.kind, name: from.name, address: from.address)))
//            }
            
        case .spamReceive(let model):
            break
//            kindRows.append(.recipient(.init(kind: transaction.kind, name: model.from.name, address: model.from.address)))
            
        case .spamMassReceived(let model):
            break
//            for from in model.from {
//                kindRows.append(.recipient(.init(kind: transaction.kind, name: from.name, address: from.address)))
//            }
            
        case .data(let model):
 
            break
//            kindRows.append(.recipient(.init(kind: transaction.kind, name: model..name, address: to.address)))
 
        case .unrecognisedTransaction:
            break
            
        }
        
//        rows.append(
//            .general(.init(kind: transaction.kind,
//                  balance: transaction.balance,
//                  currencyConversion: "≈ " + transaction.conversionBalance.money.formattedText(defaultMinimumFractionDigits: false) +  transaction.conversionBalance.currency.title))
//        )
        rows.append(contentsOf: kindRows)
//        rows.append(.recipient(.init(kind: transaction.kind, name: transaction., address: "96AFUzFKebbwmJulY6evx9GrfYBkmn8LcUL0")))
//
//        if let comment = transaction.comment {
//            rows.append(.comment(.init(text: comment)))
//        }
//
        
//        rows.append(.keyValue(.init(title: "Fee", value: transaction.fee.formattedText(defaultMinimumFractionDigits: false) + " " + transaction.balance.currency.title)))

//        rows.append(.keysValues(
//            [
//                .init(title: "Confirmations", value: String(transaction.confirmations)),
//                .init(title: "Block", value: String(transaction.height))
//            ])
//        )
        
//        rows.append(.status(.init(timestamp: String(transaction.timestamp), status: transaction.status)))
        
        switch transaction.kind {
        case .sent(_):
            rows.append(.resendButton(.init(type: .resend)))
        case .massSent(_):
            rows.append(.resendButton(.init(type: .resend)))
        case .startedLeasing(_):
            rows.append(.resendButton(.init(type: .cancelLeasing)))
        default:
            break
        }
        
        
        let generalSection = TransactionHistoryTypes.ViewModel.Section(items: rows)
        
        return [generalSection]
        
    }
    
}
