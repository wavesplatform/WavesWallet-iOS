//
//  ExchangeOrder+Assisstants.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 08/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

fileprivate enum TransactionDirection {
    case sent
    case selfSent
    case receive

    init(sender: String,
         recipient: String,
         accountAddress: String) {

        let isSenderAccount = sender.isMyAccount(accountAddress)
        let isRecipientAccount = recipient.isMyAccount(accountAddress)
        if isSenderAccount && isRecipientAccount {
            self = .selfSent
        } else if isSenderAccount {
            self = .sent
        } else {
            self = .receive
        }
    }
}

// MARK: UnrecognisedTransaction

extension Int64 {

    func confirmationHeight(txHeight: Int64) -> Int64 {
        return self - txHeight
    }
}

struct SmartTransactionMetaData {
    let accountAddress: String
    let assets: [String: DomainLayer.DTO.Asset]
    let accounts: [String: DomainLayer.DTO.Account]
    let totalHeight: Int64
    let status: DomainLayer.DTO.SmartTransaction.Status
    let mapTxs: [String: DomainLayer.DTO.AnyTransaction]
}

extension DomainLayer.DTO.UnrecognisedTransaction {

    func transaction(by metaData: SmartTransactionMetaData) -> DomainLayer.DTO.SmartTransaction? {

        let assets: [String: DomainLayer.DTO.Asset] = metaData.assets
        let accounts: [String: DomainLayer.DTO.Account] = metaData.accounts
        let totalHeight: Int64 = metaData.totalHeight

        guard let wavesAsset = assets[GlobalConstants.wavesAssetId] else {
            return nil
        }
        guard let sender = accounts[self.sender] else {
            return nil
        }

        let feeBalance = wavesAsset.balance(fee)

        return .init(id: id,
                     kind: .unrecognisedTransaction,
                     timestamp: Date(milliseconds: timestamp),
                     totalFee: feeBalance,
                     height: height,
                     confirmationHeight: totalHeight.confirmationHeight(txHeight: height),
                     sender: sender,
                     status: metaData.status)
    }
}

// MARK: IssueTransaction

extension DomainLayer.DTO.IssueTransaction {

    func transaction(by metaData: SmartTransactionMetaData) -> DomainLayer.DTO.SmartTransaction? {

        let assets: [String: DomainLayer.DTO.Asset] = metaData.assets
        let accounts: [String: DomainLayer.DTO.Account] = metaData.accounts
        let totalHeight: Int64 = metaData.totalHeight

        guard let wavesAsset = assets[GlobalConstants.wavesAssetId] else {
            return nil
        }
        guard let sender = accounts[self.sender] else {
            return nil
        }
        guard let asset = assets[self.assetId] else {
            return nil
        }
        let balance = asset.balance(self.quantity)
        let feeBalance = wavesAsset.balance(fee)

        return .init(id: id,
                     kind: .tokenGeneration(.init(asset: asset, balance: balance, description: nil)),
                     timestamp: Date(milliseconds: timestamp),
                     totalFee: feeBalance,
                     height: height,
                     confirmationHeight: totalHeight.confirmationHeight(txHeight: height),
                     sender: sender,
                     status: metaData.status)
    }
}

// MARK: TransferTransaction

extension DomainLayer.DTO.TransferTransaction {

    func transaction(by metaData: SmartTransactionMetaData) -> DomainLayer.DTO.SmartTransaction? {

        let accountAddress: String = metaData.accountAddress
        let assets: [String: DomainLayer.DTO.Asset] = metaData.assets
        let accounts: [String: DomainLayer.DTO.Account] = metaData.accounts
        let totalHeight: Int64 = metaData.totalHeight

        let assetId = self.assetId
        guard let asset = assets[assetId] else {
            return nil
        }
        guard let recipient = accounts[self.recipient] else {
            return nil
        }
        guard let sender = accounts[self.sender] else {
            return nil
        }

        let balance = asset.balance(self.amount)
        let transfer: DomainLayer.DTO.SmartTransaction.Transfer = .init(balance: balance,
                                                                        asset: asset,
                                                                        recipient: recipient,
                                                                        attachment: attachment)

        let transactionDirection = TransactionDirection(sender: self.sender,
                                                        recipient: self.recipient,
                                                        accountAddress: accountAddress)

        var kind: DomainLayer.DTO.SmartTransaction.Kind!

        switch transactionDirection {
        case .sent:
            kind = .sent(transfer)
        case .selfSent:
            kind = .selfTransfer(transfer)
        case .receive:
            if asset.isSpam {
                kind = .spamReceive(transfer)
            } else {
                kind = .receive(transfer)
            }
        }

        guard let wavesAsset = assets[GlobalConstants.wavesAssetId] else {
            return nil
        }
        let feeBalance = wavesAsset.balance(fee)

        return .init(id: id,
                     kind: kind,
                     timestamp: Date(milliseconds: timestamp),
                     totalFee: feeBalance,
                     height: height,
                     confirmationHeight: totalHeight.confirmationHeight(txHeight: height),
                     sender: sender,
                     status: metaData.status)
    }
}

// MARK: ReissueTransaction

extension DomainLayer.DTO.ReissueTransaction {

    func transaction(by metaData: SmartTransactionMetaData) -> DomainLayer.DTO.SmartTransaction? {

        let assets: [String: DomainLayer.DTO.Asset] = metaData.assets
        let accounts: [String: DomainLayer.DTO.Account] = metaData.accounts
        let totalHeight: Int64 = metaData.totalHeight

        guard let asset = assets[self.assetId] else {
            return nil
        }
        guard let sender = accounts[self.sender] else {
            return nil
        }
        guard let wavesAsset = assets[GlobalConstants.wavesAssetId] else {
            return nil
        }

        let balance = asset.balance(self.quantity)
        let feeBalance = wavesAsset.balance(fee)

        return .init(id: id,
                     kind: .tokenReissue(.init(asset: asset,
                                               balance: balance,
                                               description: nil)),
                     timestamp: Date(milliseconds: timestamp),
                     totalFee: feeBalance,
                     height: height,
                     confirmationHeight: totalHeight.confirmationHeight(txHeight: height),
                     sender: sender,
                     status: metaData.status)
    }
}

// MARK: BurnTransaction

extension DomainLayer.DTO.BurnTransaction {

    func transaction(by metaData: SmartTransactionMetaData) -> DomainLayer.DTO.SmartTransaction? {

        let assets: [String: DomainLayer.DTO.Asset] = metaData.assets
        let accounts: [String: DomainLayer.DTO.Account] = metaData.accounts
        let totalHeight: Int64 = metaData.totalHeight

        guard let asset = assets[self.assetId] else {
            return nil
        }
        guard let sender = accounts[self.sender] else {
            return nil
        }
        guard let wavesAsset = assets[GlobalConstants.wavesAssetId] else {
            return nil
        }
        let balance = asset.balance(self.amount)
        let feeBalance = wavesAsset.balance(fee)

        return .init(id: id,
                     kind: .tokenBurn(.init(asset: asset,
                                            balance: balance,
                                            description: nil)),
                     timestamp: Date(milliseconds: timestamp),
                     totalFee: feeBalance,
                     height: height,
                     confirmationHeight: totalHeight.confirmationHeight(txHeight: height),
                     sender: sender,
                     status: metaData.status)
    }
}

// MARK: ExchangeTransaction

extension DomainLayer.DTO.ExchangeTransaction {

    func transaction(by metaData: SmartTransactionMetaData) -> DomainLayer.DTO.SmartTransaction? {

        let assets: [String: DomainLayer.DTO.Asset] = metaData.assets
        let accounts: [String: DomainLayer.DTO.Account] = metaData.accounts
        let totalHeight: Int64 = metaData.totalHeight

        let amountAssetId = order1.assetPair.amountAsset
        let priceAssetId = order1.assetPair.priceAsset
        guard let wavesAsset = assets[GlobalConstants.wavesAssetId] else {
            return nil
        }
        guard let amountAsset = assets[amountAssetId] else {
            return nil
        }
        guard let priceAsset = assets[priceAssetId] else {
            return nil
        }
        let assetPair = DomainLayer.DTO.AssetPair(amountAsset: amountAsset,
                                                  priceAsset: priceAsset)

        let amount = assetPair.amountBalance(self.amount)
        let price = assetPair.priceBalance(self.price)
        let total = assetPair.totalBalance(priceAmount: self.price,
                                           assetAmount: self.amount)

        let buyMatcherFee = wavesAsset.balance(self.buyMatcherFee)
        let sellMatcherFee = wavesAsset.balance(self.sellMatcherFee)

        guard let order1 = order1.exchangeOrder(assetPair: assetPair,
                                                accounts: accounts)
            else {
                return nil
            }
        guard let order2 = order2.exchangeOrder(assetPair: assetPair,
                                                accounts: accounts)
            else {
                return nil
            }

        let kind: DomainLayer.DTO.SmartTransaction.Kind = .exchange(.init(price: price,
                                                                          amount: amount,
                                                                          total: total,
                                                                          buyMatcherFee: buyMatcherFee,
                                                                          sellMatcherFee: sellMatcherFee,
                                                                          order1: order1,
                                                                          order2: order2))

        //TODO: Проверить комиссию для одного sendera
        let feeBalance = wavesAsset.balance(fee)

        guard let sender = accounts[self.sender] else {
            return nil            
        }

        return .init(id: id,
                     kind: kind,
                     timestamp: Date(milliseconds: timestamp),
                     totalFee: feeBalance,
                     height: height,
                     confirmationHeight: totalHeight.confirmationHeight(txHeight: height),
                     sender: sender,
                     status: metaData.status)
    }
}

// MARK: LeaseTransaction

extension DomainLayer.DTO.LeaseTransaction {

    func transaction(by metaData: SmartTransactionMetaData) -> DomainLayer.DTO.SmartTransaction? {

        let accountAddress: String = metaData.accountAddress
        let assets: [String: DomainLayer.DTO.Asset] = metaData.assets
        let accounts: [String: DomainLayer.DTO.Account] = metaData.accounts
        let totalHeight: Int64 = metaData.totalHeight

        guard let wavesAsset = assets[GlobalConstants.wavesAssetId] else { return nil }
        let balance = wavesAsset.balance(self.amount)
        let isSenderAccount = sender.isMyAccount(accountAddress)

        var kind: DomainLayer.DTO.SmartTransaction.Kind!

        if isSenderAccount {
            guard let recipient = accounts[self.recipient] else { return nil }
            kind = .startedLeasing(.init(asset: wavesAsset,
                                         balance: balance,
                                         account: recipient))
        } else {
            guard let sender = accounts[self.sender] else { return nil }
            kind = .incomingLeasing(.init(asset: wavesAsset,
                                          balance: balance,
                                          account: sender))
        }

        let feeBalance = wavesAsset.balance(fee)

        guard let sender = accounts[self.sender] else { return nil }

        return .init(id: id,
                     kind: kind,
                     timestamp: Date(milliseconds: timestamp),
                     totalFee: feeBalance,
                     height: height,
                     confirmationHeight: totalHeight.confirmationHeight(txHeight: height),
                     sender: sender,
                     status: metaData.status)
    }
}

// MARK: LeaseCancelTransaction

extension DomainLayer.DTO.LeaseCancelTransaction {

    func transaction(by metaData: SmartTransactionMetaData) -> DomainLayer.DTO.SmartTransaction? {
        
        let assets: [String: DomainLayer.DTO.Asset] = metaData.assets
        let accounts: [String: DomainLayer.DTO.Account] = metaData.accounts
        let totalHeight: Int64 = metaData.totalHeight

        var optionalLease = self.lease

        if optionalLease == nil {
            optionalLease = metaData.mapTxs[self.leaseId]?.leaseTransaction
        }

        guard let lease = optionalLease else {
            return nil
        }

        guard let wavesAsset = assets[GlobalConstants.wavesAssetId] else {

            return nil
        }
        guard let recipient = accounts[lease.recipient] else {

            return nil
        }
        guard let sender = accounts[self.sender] else {

            return nil
        }

        let balance = wavesAsset.balance(lease.amount)

        let kind: DomainLayer.DTO.SmartTransaction.Kind = .canceledLeasing(.init(asset: wavesAsset,
                                                                                 balance: balance,
                                                                                 account: recipient))

        let feeBalance = wavesAsset.balance(fee)

        return .init(id: id,
                     kind: kind,
                     timestamp: Date(milliseconds: timestamp),
                     totalFee: feeBalance,
                     height: height,
                     confirmationHeight: totalHeight.confirmationHeight(txHeight: height),
                     sender: sender,
                     status: metaData.status)
    }
}

// MARK: AliasTransaction

extension DomainLayer.DTO.AliasTransaction {

    func transaction(by metaData: SmartTransactionMetaData) -> DomainLayer.DTO.SmartTransaction? {
        
        let assets: [String: DomainLayer.DTO.Asset] = metaData.assets
        let accounts: [String: DomainLayer.DTO.Account] = metaData.accounts
        let totalHeight: Int64 = metaData.totalHeight

        guard let wavesAsset = assets[GlobalConstants.wavesAssetId] else { return nil }
        guard let sender = accounts[self.sender] else { return nil }

        let kind: DomainLayer.DTO.SmartTransaction.Kind = .createdAlias(alias)
        let feeBalance = wavesAsset.balance(fee)

        //TODO: confirmationHeight is nil?
        return .init(id: id,
                     kind: kind,
                     timestamp: Date(milliseconds: timestamp),
                     totalFee: feeBalance,
                     height: height,
                     confirmationHeight: totalHeight.confirmationHeight(txHeight: height ?? -1),
                     sender: sender,
                     status: metaData.status)
    }
}

// MARK: MassTransferTransaction

extension DomainLayer.DTO.MassTransferTransaction {

    func transaction(by metaData: SmartTransactionMetaData) -> DomainLayer.DTO.SmartTransaction? {

        let assets: [String: DomainLayer.DTO.Asset] = metaData.assets
        let accounts: [String: DomainLayer.DTO.Account] = metaData.accounts
        let totalHeight: Int64 = metaData.totalHeight

        let assetId = self.assetId
        guard let asset = assets[assetId] else {
            return nil

        }
        guard let sender = accounts[self.sender] else {
            return nil
        }

        let totalBalance = asset.balance(self.totalAmount)

        let transfers = self.transfers.map { tx -> DomainLayer.DTO.SmartTransaction.MassTransfer.Transfer? in
            guard let recipient = accounts[tx.recipient] else {
                return nil
            }
            let amount = asset.money(tx.amount)
            return .init(amount: amount, recipient: recipient)
        }
        .compactMap { $0 }

        let massTransfer: DomainLayer.DTO.SmartTransaction.MassTransfer = .init(total: totalBalance,
                                                                                asset: asset,
                                                                                attachment: attachment,
                                                                                transfers: transfers)
        let isSenderAccount = sender.isMyAccount

        var kind: DomainLayer.DTO.SmartTransaction.Kind!

        if isSenderAccount {
            kind = .massSent(massTransfer)
        } else {
            if asset.isSpam {
                kind = .spamMassReceived(massTransfer)
            } else {
                kind = .massReceived(massTransfer)
            }
        }

        guard let wavesAsset = assets[GlobalConstants.wavesAssetId] else {
            return nil
        }
        let feeBalance = wavesAsset.balance(fee)

        return .init(id: id,
                     kind: kind,
                     timestamp: Date(milliseconds: timestamp),
                     totalFee: feeBalance,
                     height: height,
                     confirmationHeight: totalHeight.confirmationHeight(txHeight: height),
                     sender: sender,
                     status: metaData.status)
    }
}

// MARK: DataTransaction

extension DomainLayer.DTO.DataTransaction {

    func transaction(by metaData: SmartTransactionMetaData) -> DomainLayer.DTO.SmartTransaction? {

        let assets: [String: DomainLayer.DTO.Asset] = metaData.assets
        let accounts: [String: DomainLayer.DTO.Account] = metaData.accounts
        let totalHeight: Int64 = metaData.totalHeight

        //TODO: Constants
        let list = data.map { data -> [String: String] in
            var map = [String: String]()
            map["key"] = data.key
            map["type"] = data.type
            map["value"] = data.value.toString
            return map
        }

        let prettyJSON = list.prettyJSON ?? ""
        let kind: DomainLayer.DTO.SmartTransaction.Kind = .data(.init(prettyJSON: prettyJSON))

        guard let wavesAsset = assets[GlobalConstants.wavesAssetId] else { return nil }
        guard let sender = accounts[self.sender] else { return nil }
        let feeBalance = wavesAsset.balance(fee)

        return .init(id: id,
                     kind: kind,
                     timestamp: Date(milliseconds: timestamp),
                     totalFee: feeBalance,
                     height: height,
                     confirmationHeight: totalHeight.confirmationHeight(txHeight: height),
                     sender: sender,
                     status: metaData.status)
    }
}

extension DomainLayer.DTO.AnyTransaction {

    func transaction(by accountAddress: String,
                     assets: [String: DomainLayer.DTO.Asset],
                     accounts: [String: DomainLayer.DTO.Account],
                     totalHeight: Int64,
                     leaseTransactions: [String: DomainLayer.DTO.LeaseTransaction],
                     mapTxs: [String: DomainLayer.DTO.AnyTransaction]) -> DomainLayer.DTO.SmartTransaction? {

        var status: DomainLayer.DTO.SmartTransaction.Status = .completed

        switch self.status {
            case .activeNow:
                status = .activeNow

            case .completed:
                status = .completed

            case .unconfirmed:
                status = .unconfirmed
        }

        if self.isLease && leaseTransactions[id] != nil {
            status = .activeNow
        }

        let smartData = SmartTransactionMetaData(accountAddress: accountAddress,
                                                 assets: assets,
                                                 accounts: accounts,
                                                 totalHeight: totalHeight,
                                                 status: status,
                                                 mapTxs: mapTxs)

        var smartTransaction: DomainLayer.DTO.SmartTransaction?
        switch self {

        case .unrecognised(let tx):
            smartTransaction = tx.transaction(by: smartData)

        case .issue(let tx):
            smartTransaction = tx.transaction(by: smartData)

        case .transfer(let tx):
            smartTransaction = tx.transaction(by: smartData)

        case .reissue(let tx):
            smartTransaction = tx.transaction(by: smartData)

        case .burn(let tx):
            smartTransaction = tx.transaction(by: smartData)

        case .exchange(let tx):
            smartTransaction = tx.transaction(by: smartData)

        case .lease(let tx):
            smartTransaction = tx.transaction(by: smartData)

        case .leaseCancel(let tx):
            smartTransaction = tx.transaction(by: smartData)

        case .alias(let tx):
            smartTransaction = tx.transaction(by: smartData)

        case .massTransfer(let tx):
            smartTransaction = tx.transaction(by: smartData)

        case .data(let tx):
            smartTransaction = tx.transaction(by: smartData)
        }

        if smartTransaction == nil {
           debug(self)
        }

        return smartTransaction
    }
}

fileprivate extension String {

    func isMyAccount(_ account: String) -> Bool {
        return self == account
    }
}

extension DomainLayer.DTO.ExchangeTransaction.Order {

    func exchangeOrder(assetPair: DomainLayer.DTO.AssetPair,
                       accounts: [String: DomainLayer.DTO.Account]) -> DomainLayer.DTO.SmartTransaction.Exchange.Order? {

        guard let sender = accounts[self.sender] else { return nil }
        let kind: DomainLayer.DTO.SmartTransaction.Exchange.Order.Kind = orderType == .sell ? .sell : .buy
        let amount = assetPair.amountBalance(self.amount)
        let price = assetPair.priceBalance(self.price)
        let total = assetPair.totalBalance(priceAmount: self.amount,
                                           assetAmount: self.price)

        return .init(timestamp: Date(milliseconds: timestamp),
                     expiration: Date(milliseconds: expiration),
                     sender: sender,
                     kind: kind,
                     pair: assetPair,
                     price: price,
                     amount: amount,
                     total: total)
    }
}

fileprivate extension DomainLayer.DTO.DataTransaction.Data.Value {

    var toString: String {
        switch self {
        case .bool(let value):
            return "\(value)"

        case .integer(let value):
            return "\(value)"

        case .string(let value):
            return "\(value)"

        case .binary(let value):
            return "\(value)"
        }
    }
}
