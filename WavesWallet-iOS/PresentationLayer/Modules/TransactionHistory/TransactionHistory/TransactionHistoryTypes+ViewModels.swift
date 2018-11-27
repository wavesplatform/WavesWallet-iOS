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
        let isSpam: Bool
        let canGoBack: Bool?
        let canGoForward: Bool?
        let exchangeSubtitle: String?
    }
    
    struct Recipient {
        let kind: DomainLayer.DTO.SmartTransaction.Kind
        let account: DomainLayer.DTO.Account
        let amount: Money?
        let isHiddenTitle: Bool
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
        enum Kind: Hashable {
            case activeNow
            case unconfirmed
            case completed
        }
        let timestamp: Date
        let status: Kind
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
        var kindRows: [TransactionHistoryTypes.ViewModel.Row] = []
        
        var balance: Balance?
        var comment: String?
        var sign: Balance.Sign = .none
        var asset: DomainLayer.DTO.Asset?
        var customTitle: String?
        var exchangeSubtitle: String?
        
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
                        account: model.recipient,
                        amount: nil,
                        isHiddenTitle: false)
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
                        account: model.recipient,
                        amount: nil,
                        isHiddenTitle: false)
                ))
            
        case .startedLeasing(let model):
            balance = model.balance
            asset = model.asset
            
            kindRows.append(
                .recipient(
                .init(
                    kind: transaction.kind,
                    account: model.account,
                    amount: nil,
                    isHiddenTitle: false)
                ))
            
        case .exchange(let model):
            
            let myOrder = model.myOrder
            var valueType = ""
            
            if myOrder.kind == .sell {
                sign = .minus
                valueType = Localizable.Waves.Transactionhistory.Cell.sell(model.amount.currency.title, model.price.currency.title)
                exchangeSubtitle = myOrder.total.displayText(sign: .plus, withoutCurrency: false)
            } else {
                sign = .plus
                valueType = Localizable.Waves.Transactionhistory.Cell.buy(model.amount.currency.title, model.price.currency.title)
                exchangeSubtitle = myOrder.total.displayText(sign: .minus, withoutCurrency: false)
            }
            
            balance = model.amount
                                    
            kindRows.append(.keyValue(.init(title: Localizable.Waves.Transactionhistory.Cell.type,
                                            value: valueType)))
            
            kindRows.append(
                .keyValue(
                .init(
                    title: Localizable.Waves.Transactionhistory.Cell.price,
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
                    title: Localizable.Waves.Transactionhistory.Cell.id,
                    value: model.asset.id,
                    subvalue: model.asset.isReusable ? Localizable.Waves.Transactionhistory.Cell.reissuable : Localizable.Waves.Transactionhistory.Cell.notReissuable)
                ))
            
        case .tokenReissue(let model):
            balance = model.balance
            comment = model.description
            sign = .plus
            asset = model.asset
            
            kindRows.append(
                .keyValue(
                .init(
                    title: Localizable.Waves.Transactionhistory.Cell.id,
                    value: model.asset.id,
                    subvalue: model.asset.isReusable ?
                        Localizable.Waves.Transactionhistory.Cell.reissuable : Localizable.Waves.Transactionhistory.Cell.notReissuable)
                ))
            
        case .tokenBurn(let model):
            balance = model.balance
            comment = model.description
            sign = .minus
            asset = model.asset
            
            kindRows.append(
                .keyValue(
                .init(
                    title: Localizable.Waves.Transactionhistory.Cell.id,
                    value: model.asset.id,
                    subvalue: model.asset.isReusable ? Localizable.Waves.Transactionhistory.Cell.reissuable : Localizable.Waves.Transactionhistory.Cell.notReissuable)
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
                    account: model.account,
                    amount: nil,
                    isHiddenTitle: false)
                ))
            
        case .incomingLeasing(let model):
            balance = model.balance
            asset = model.asset
            sign = .minus
            
            kindRows.append(
                .recipient(
                .init(
                    kind: transaction.kind,
                    account: model.account,
                    amount: nil,
                    isHiddenTitle: false)
                ))
            
        case .massSent(let model):
            comment = model.attachment
            balance = model.total
            asset = model.asset
            sign = .minus
            
            for element in model.transfers.enumerated() {

                let transfer = element.element
                let isHiddenTitle = element.offset != 0
                 kindRows.append(
                    .recipient(
                    .init(
                        kind: transaction.kind,
                        account: transfer.recipient,
                        amount: transfer.amount,
                        isHiddenTitle: isHiddenTitle)
                    ))
            }
            
        case .massReceived(let model):
            comment = model.attachment
            balance = model.myTotal
            asset = model.asset
            sign = .plus

            for element in model.transfers.enumerated() {
                let transfer = element.element
                let isHiddenTitle = element.offset != 0
                kindRows.append(.recipient(.init(kind: transaction.kind,
                                                 account: transfer.recipient,
                                                 amount: nil,
                                                 isHiddenTitle: isHiddenTitle))
                )
            }
            
        case .spamReceive(let model):
            comment = model.attachment
            balance = model.balance
            asset = model.asset
            sign = .plus

            kindRows.append(
                .recipient(
                .init(
                    kind: transaction.kind,
                    account: model.recipient,
                    amount: nil,
                    isHiddenTitle: false)
                ))
            
        case .spamMassReceived(let model):
            comment = model.attachment
            balance = model.myTotal
            asset = model.asset
            sign = .plus

            
            for element in model.transfers.enumerated() {
                let transfer = element.element
                let isHiddenTitle = element.offset != 0

                kindRows.append(
                    .recipient(
                    .init(
                        kind: transaction.kind,
                        account: transfer.recipient,
                        amount: transfer.amount,
                        isHiddenTitle: isHiddenTitle)
                    ))
            }
            
        case .data:
            customTitle = Localizable.Waves.Transactionhistory.Cell.dataTransaction
            
        case .unrecognisedTransaction:
            break
        }

        // general
        
        rows.append(
            transaction.generalRow(balance: balance,
                                   sign: sign,
                                   customTitle: customTitle,
                                   asset: asset,
                                   isSpam: asset?.isSpam ?? false,
                                   canGoBack: index > 0,
                                   canGoForward: index < count - 1,
                                   exchangeSubtitle: exchangeSubtitle)
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
    
    func generalRow(balance: Balance?,
                    sign: Balance.Sign?,
                    customTitle: String?,
                    asset: DomainLayer.DTO.Asset?,
                    isSpam: Bool,
                    canGoBack: Bool?,
                    canGoForward: Bool?,
                    exchangeSubtitle: String?) -> TransactionHistoryTypes.ViewModel.Row {
        
        return
            .general(
                .init(
                    kind: kind,
                    balance: balance,
                    sign: sign,
                    customTitle: customTitle,
                    asset: asset,
                    isSpam: isSpam,
                    canGoBack: canGoBack,
                    canGoForward: canGoForward,
                    exchangeSubtitle: exchangeSubtitle)
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
                .init(title: Localizable.Waves.Transactionhistory.Cell.fee,
                  value: totalFee.displayText)
            )
    }

    //TODO: Height == -1
    func confirmationsBlockRow() -> TransactionHistoryTypes.ViewModel.Row {
        return .keysValues(
            [
                .init(
                    title: Localizable.Waves.Transactionhistory.Cell.confirmations,
                    value: String(confirmationHeight)
                ),
                .init(
                    title: Localizable.Waves.Transactionhistory.Cell.block,
                    value: String(height ?? -1)
                )
            ])
    }
    
    func statusRow() -> TransactionHistoryTypes.ViewModel.Row {
        return .status(.init(timestamp: timestamp,
                             status: self.statusKind))
    }

    var statusKind: TransactionHistoryTypes.ViewModel.Status.Kind {
        switch self.status {
        case .activeNow:
            return .activeNow

        case .completed:
            return .completed

        case .unconfirmed:
            return .unconfirmed
        }
    }
    

    func buttonRow() -> TransactionHistoryTypes.ViewModel.Row? {
        
        switch kind {
        case .sent(_):
            return .resendButton(.init(type: .resend))

        case .massSent(_):
            return .resendButton(.init(type: .resend))

        case .startedLeasing(_):
            if case .activeNow = self.status {
                return .resendButton(.init(type: .cancelLeasing))
            }
            return nil

        default:
            break
        }
        
        return nil
        
    }
    
}
