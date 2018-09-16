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
        let balance: Balance?
        let sign: Balance.Sign?
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
        let timestamp: Date
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
        
        var balance: Balance?
        var comment: String?
        var sign: Balance.Sign = .none
        
        switch transaction.kind {
        case .receive(let model):
            balance = model.balance
            comment = model.attachment
            sign = .plus
            
            kindRows.append(.recipient(.init(kind: transaction.kind, name: model.recipient.contact?.name, address: model.recipient.id)))

        case .sent(let model):
            balance = model.balance
            comment = model.attachment
            sign = .minus

            kindRows.append(.recipient(.init(kind: transaction.kind, name: model.recipient.contact?.name, address: model.recipient.id)))
            
        case .startedLeasing(let model):
            balance = model.balance
            
            kindRows.append(.recipient(.init(kind: transaction.kind, name: model.account.contact?.name, address: model.account.id)))
            
        case .exchange(let model):
            
            let myOrder = model.myOrder
            
            if myOrder.kind == .sell {
                sign = .plus
            } else {
                sign = .minus
            }
            
            balance = model.total
            
            kindRows.append(.keyValue(.init(title: model.price.currency.title + " Price", value: model.price.displayText)))
            
        case .selfTransfer(let model):
            balance = model.balance
            comment = model.attachment
            
        case .tokenGeneration(let model):
            balance = model.balance
            comment = model.description
            
            kindRows.append(.keyValue(.init(title: "ID", value: model.asset.id, subvalue: model.asset.isReusable ? "Reissuable" : "Not Reissuable")))
            
        case .tokenReissue(let model):
            balance = model.balance
            comment = model.description
            sign = .plus
            
            kindRows.append(.keyValue(.init(title: "ID", value: model.asset.id, subvalue: model.asset.isReusable ? "Reissuable" : "Not Reissuable")))
            
        case .tokenBurn(let model):
            balance = model.balance
            comment = model.description
            sign = .minus
            
            kindRows.append(.keyValue(.init(title: "ID", value: model.asset.id, subvalue: model.asset.isReusable ? "Reissuable" : "Not Reissuable")))
            
        case .createdAlias:
            break
        case .canceledLeasing(let model):
            balance = model.balance

            kindRows.append(.recipient(.init(kind: transaction.kind, name: model.account.contact?.name, address: model.account.id)))

            
        case .incomingLeasing(let model):
            balance = model.balance
            sign = .minus
            
            kindRows.append(.recipient(.init(kind: transaction.kind, name: model.account.contact?.name, address: model.account.id)))
            
        case .massSent(let model):
            comment = model.attachment
            balance = model.total
            sign = .minus
            
            for transfer in model.transfers {
                 kindRows.append(.recipient(.init(kind: transaction.kind, name: transfer.recipient.contact?.name, address: transfer.recipient.id)))
            }
            
        case .massReceived(let model):
            comment = model.attachment
            balance = model.total
            sign = .plus

            for transfer in model.transfers {
                kindRows.append(.recipient(.init(kind: transaction.kind, name: transfer.recipient.contact?.name, address: transfer.recipient.id)))
            }
            
        case .spamReceive(let model):
            comment = model.attachment
            balance = model.balance
            
            kindRows.append(.recipient(.init(kind: transaction.kind, name: model.recipient.contact?.name, address: model.recipient.id)))
            
        case .spamMassReceived(let model):
            comment = model.attachment
            balance = model.total
            
            for transfer in model.transfers {
                kindRows.append(.recipient(.init(kind: transaction.kind, name: transfer.recipient.contact?.name, address: transfer.recipient.id)))
            }
            
        case .data:
            break
        case .unrecognisedTransaction:
            break
        }
        
        // general
        
        rows.append(
            .general(
                .init(
                    kind: transaction.kind,
                    balance: balance,
                    sign: sign,
                    currencyConversion: nil
                )
            )
        )
        
        // custom rows
        
        rows.append(contentsOf: kindRows)

        // optional comment
        
        if (comment != nil) && comment!.count > 0 {
            rows.append(
                .comment(
                    .init(text: comment!)
                )
            )
        }

        // fee
        
        rows.append(.keyValue(
            .init(title: "Fee",
                  value: transaction.totalFee.displayText))
        )

        // confirmations/block
        
        rows.append(.keysValues(
            [
                .init(
                    title: "Confirmations",
                    value: String(transaction.confirmationHeight)
                ),
                .init(
                    title: "Block",
                    value: String(transaction.height)
                )
            ])
        )
        
        // timestamp and status
        
        rows.append(.status(
            .init(
                timestamp: transaction.timestamp,
                status: .activeNow)
            )
        )
        
        // button
        
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
