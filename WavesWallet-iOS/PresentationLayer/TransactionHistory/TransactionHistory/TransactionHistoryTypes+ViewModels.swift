//
//  TransactionHistoryTypes+ViewModels.swift
//  WavesWallet-iOS
//
//  Created by Mac on 24/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension TransactionHistoryTypes.ViewModel {
    struct General {
        let kind: DomainLayer.DTO.SmartTransaction.Kind
        let balance: Balance?
        let sign: Balance.Sign?
        let customTitle: String?
        let asset: DomainLayer.DTO.Asset?
        let isSpam: Bool?
        let currencyConversion: String?
        let canGoBack: Bool?
        let canGoForward: Bool?
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
    
    static func map(from transaction: DomainLayer.DTO.SmartTransaction, index: Int, count: Int) -> [TransactionHistoryTypes.ViewModel.Section] {
        
        var rows: [TransactionHistoryTypes.ViewModel.Row] = []
        var kindRows: [TransactionHistoryTypes.ViewModel.Row] = [] // lisichka
        
        var balance: Balance?
        var comment: String?
        var sign: Balance.Sign = .none
        var asset: DomainLayer.DTO.Asset?
        var isSpam: Bool?
        var customTitle: String?
        var currencyConversion: String?
        
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
                    name: model.recipient.contact?.name,
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
                currencyConversion = myOrder.amount.displayText(sign: .minus, withoutCurrency: false)
            } else {
                sign = .minus
                currencyConversion = myOrder.amount.displayText(sign: .plus, withoutCurrency: false)
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
            sign = .plus
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
            sign = .plus
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
            transaction.generalRow(balance: balance, sign: sign, customTitle: customTitle, asset: asset, currencyConversion: currencyConversion, isSpam: isSpam, canGoBack: index > 0, canGoForward: index < count - 1)
        )
        
        // custom rows
        
        rows.append(contentsOf: kindRows)

        // optional comment
        
        if let commentRow = transaction.commentRow(comment: comment) {
            rows.append(commentRow)
        }

        // fee
        
        rows.append(transaction.feeRow())

        // confirmations/block
        
        rows.append(transaction.confirmationsBlockRow())
        
        // timestamp and status
        
        rows.append(transaction.statusRow())
        
        // button
        
        if let buttonRow = transaction.buttonRow() {
            rows.append(buttonRow)
        }
        
        let generalSection = TransactionHistoryTypes.ViewModel.Section(transaction: transaction, items: rows)
        
        return [generalSection]
        
    }
    
    
    
}

fileprivate extension DomainLayer.DTO.SmartTransaction {
    
    func generalRow(balance: Balance?, sign: Balance.Sign?, customTitle: String?, asset: DomainLayer.DTO.Asset?, currencyConversion: String?, isSpam: Bool?, canGoBack: Bool?, canGoForward: Bool?) -> TransactionHistoryTypes.ViewModel.Row {
        
        return
            .general(
                .init(
                    kind: kind,
                    balance: balance,
                    sign: sign,
                    customTitle: customTitle,
                    asset: asset,
                    isSpam: isSpam,
                    currencyConversion: currencyConversion,
                    canGoBack: canGoBack,
                    canGoForward: canGoForward
                )
            )
        
    }
    
    func commentRow(comment: String?) -> TransactionHistoryTypes.ViewModel.Row? {
        
        if (comment != nil) && comment!.count > 0 {
            return
                .comment(
                    .init(text: comment!)
                )
        }
        
        return nil
        
    }
    
    func feeRow() -> TransactionHistoryTypes.ViewModel.Row {
        return
            .keyValue(
                .init(title: Localizable.TransactionHistory.Cell.fee,
                  value: totalFee.displayText)
            )
    }
    
    func confirmationsBlockRow() -> TransactionHistoryTypes.ViewModel.Row {
        return .keysValues(
            [
                .init(
                    title: Localizable.TransactionHistory.Cell.confirmations,
                    value: String(confirmationHeight)
                ),
                .init(
                    title: Localizable.TransactionHistory.Cell.block,
                    value: String(height)
                )
            ])
    }
    
    func statusRow() -> TransactionHistoryTypes.ViewModel.Row {
        return .status(.init(
            timestamp: timestamp,
            status: .activeNow)
        )
    }
    
    
    func buttonRow() -> TransactionHistoryTypes.ViewModel.Row? {
        
        switch kind {
        case .sent(_):
            return .resendButton(.init(type: .resend))
        case .massSent(_):
            return .resendButton(.init(type: .resend))
        case .startedLeasing(_):
            return .resendButton(.init(type: .cancelLeasing))
        default:
            break
        }
        
        return nil
        
    }
    
}
