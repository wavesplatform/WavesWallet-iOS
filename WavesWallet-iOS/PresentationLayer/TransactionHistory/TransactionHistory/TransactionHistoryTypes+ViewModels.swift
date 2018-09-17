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
        let customTitle: String?
        let asset: DomainLayer.DTO.Asset?
        let isSpam: Bool?
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
        var transaction: DomainLayer.DTO.SmartTransaction
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
        var asset: DomainLayer.DTO.Asset?
        var isSpam: Bool?
        var customTitle: String?
        
        switch transaction.kind {
        case .receive(let model):
            balance = model.balance
            comment = model.attachment
            asset = model.asset
            sign = .plus
            
            kindRows.append(
                .recipient(
                .init(
                    kind: transaction.kind,
                    name: model.recipient.contact?.name ?? "mr. big",
                    address: model.recipient.id)
                ))

        case .sent(let model):
            balance = model.balance
            comment = model.attachment
            asset = model.asset
            sign = .minus

            kindRows.append(
                .recipient(
                .init(
                    kind: transaction.kind,
                    name: model.recipient.contact?.name,
                    address: model.recipient.id)
                ))
            
        case .startedLeasing(let model):
            balance = model.balance
            asset = model.asset
            
            kindRows.append(
                .recipient(
                .init(
                    kind: transaction.kind,
                    name: model.account.contact?.name,
                    address: model.account.id)
                ))
            
        case .exchange(let model):
            
            let myOrder = model.myOrder
            
            if myOrder.kind == .sell {
                sign = .plus
            } else {
                sign = .minus
            }
            
            balance = model.total
            
            kindRows.append(
                .keyValue(
                .init(
                    title: model.price.currency.title + " " + Localizable.TransactionHistory.Cell.price,
                    value: model.price.displayText)
                ))
            
        case .selfTransfer(let model):
            balance = model.balance
            comment = model.attachment
            asset = model.asset
            
        case .tokenGeneration(let model):
            balance = model.balance
            comment = model.description
            asset = model.asset
            
            kindRows.append(
                .keyValue(
                .init(
                    title: Localizable.TransactionHistory.Cell.id,
                    value: model.asset.id,
                    subvalue: model.asset.isReusable ? Localizable.TransactionHistory.Cell.reissuable : Localizable.TransactionHistory.Cell.notReissuable)
                ))
            
        case .tokenReissue(let model):
            balance = model.balance
            comment = model.description
            sign = .plus
            asset = model.asset
            
            kindRows.append(
                .keyValue(
                .init(
                    title: Localizable.TransactionHistory.Cell.id,
                    value: model.asset.id,
                    subvalue: model.asset.isReusable ?
                        Localizable.TransactionHistory.Cell.reissuable : Localizable.TransactionHistory.Cell.notReissuable)
                ))
            
        case .tokenBurn(let model):
            balance = model.balance
            comment = model.description
            sign = .minus
            
            kindRows.append(
                .keyValue(
                .init(
                    title: Localizable.TransactionHistory.Cell.id,
                    value: model.asset.id,
                    subvalue: model.asset.isReusable ? Localizable.TransactionHistory.Cell.reissuable : Localizable.TransactionHistory.Cell.notReissuable)
                ))
            
        case .createdAlias(let model):
            customTitle = model
        case .canceledLeasing(let model):
            balance = model.balance
            asset = model.asset

            kindRows.append(
                .recipient(
                .init(
                    kind: transaction.kind,
                    name: model.account.contact?.name,
                    address: model.account.id)
                ))
            
        case .incomingLeasing(let model):
            balance = model.balance
            asset = model.asset
            sign = .minus
            
            kindRows.append(
                .recipient(
                .init(
                    kind: transaction.kind,
                    name: model.account.contact?.name,
                    address: model.account.id)
                ))
            
        case .massSent(let model):
            comment = model.attachment
            balance = model.total
            asset = model.asset
            sign = .minus
            
            for transfer in model.transfers {
                 kindRows.append(
                    .recipient(
                    .init(
                        kind: transaction.kind,
                        name: transfer.recipient.contact?.name,
                        address: transfer.recipient.id)
                    ))
            }
            
        case .massReceived(let model):
            comment = model.attachment
            balance = model.total
            asset = model.asset
            sign = .plus

            for transfer in model.transfers {
                kindRows.append(
                    .recipient(
                    .init(
                        kind: transaction.kind,
                        name: transfer.recipient.contact?.name,
                        address: transfer.recipient.id)
                    ))
            }
            
        case .spamReceive(let model):
            comment = model.attachment
            balance = model.balance
            asset = model.asset
            isSpam = true
            
            kindRows.append(
                .recipient(
                .init(
                    kind: transaction.kind,
                    name: model.recipient.contact?.name,
                    address: model.recipient.id)
                ))
            
        case .spamMassReceived(let model):
            comment = model.attachment
            balance = model.total
            asset = model.asset
            isSpam = true
            
            for transfer in model.transfers {
                kindRows.append(
                    .recipient(
                    .init(
                        kind: transaction.kind,
                        name: transfer.recipient.contact?.name,
                        address: transfer.recipient.id)
                    ))
            }
            
        case .data:
            customTitle = Localizable.TransactionHistory.Cell.dataTransaction
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
                    customTitle: customTitle,
                    asset: asset,
                    isSpam: isSpam,
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
            .init(title: Localizable.TransactionHistory.Cell.fee,
                  value: transaction.totalFee.displayText))
        )

        // confirmations/block
        
        rows.append(.keysValues(
            [
                .init(
                    title: Localizable.TransactionHistory.Cell.confirmations,
                    value: String(transaction.confirmationHeight)
                ),
                .init(
                    title: Localizable.TransactionHistory.Cell.block,
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
        
        let generalSection = TransactionHistoryTypes.ViewModel.Section(transaction: transaction, items: rows)
        
        return [generalSection]
        
    }
    
}
