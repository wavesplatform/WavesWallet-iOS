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

extension DomainLayer.DTO.UnrecognisedTransaction {

    func transaction(by accountAddress: String, assets: [String: DomainLayer.DTO.Asset]) -> DomainLayer.DTO.Transaction? {

        guard let wavesAsset = assets[Environments.Constants.wavesAssetId] else { return nil }
        let feeBalance = wavesAsset.balance(fee)

        return .init(id: id,
                     kind: .unrecognisedTransaction,
                     timestamp: Date(milliseconds: timestamp), totalFee: feeBalance, height: height)
    }
}

// MARK: IssueTransaction

extension DomainLayer.DTO.IssueTransaction {

    func transaction(by accountAddress: String, assets: [String: DomainLayer.DTO.Asset]) -> DomainLayer.DTO.Transaction? {

        guard let wavesAsset = assets[Environments.Constants.wavesAssetId] else { return nil }
        let feeBalance = wavesAsset.balance(fee)

        return .init(id: id,
                     kind: .unrecognisedTransaction,
                     timestamp: Date(milliseconds: timestamp), totalFee: feeBalance, height: height)
    }
}

// MARK: TransferTransaction

extension DomainLayer.DTO.TransferTransaction {

    func transaction(by accountAddress: String,
                     assets: [String: DomainLayer.DTO.Asset],
                     accounts: [String: DomainLayer.DTO.Account]) -> DomainLayer.DTO.Transaction? {

        guard let assetId = self.assetId else { return nil }
        guard let asset = assets[assetId] else { return nil }
        guard let recipient = accounts[self.recipient] else { return nil }

        let balance = asset.balance(self.amount)
        let transfer: DomainLayer.DTO.Transaction.Transfer = .init(balance: balance,
                                                                   asset: asset,
                                                                   recipient: recipient)

        let transactionDirection = TransactionDirection(sender: self.sender,
                                                        recipient: self.recipient,
                                                        accountAddress: accountAddress)

        var kind: DomainLayer.DTO.Transaction.Kind!

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

        guard let wavesAsset = assets[Environments.Constants.wavesAssetId] else { return nil }
        let feeBalance = wavesAsset.balance(fee)

        return .init(id: id,
                     kind: kind,
                     timestamp: Date(milliseconds: timestamp), totalFee: feeBalance, height: height)
    }
}

// MARK: ReissueTransaction

extension DomainLayer.DTO.ReissueTransaction {

    func transaction(by accountAddress: String,
                     assets: [String: DomainLayer.DTO.Asset]) -> DomainLayer.DTO.Transaction? {

        guard let asset = assets[self.assetId] else { return nil }
        let balance = asset.balance(self.quantity)
        guard let wavesAsset = assets[Environments.Constants.wavesAssetId] else { return nil }
        let feeBalance = wavesAsset.balance(fee)

        return .init(id: id,
                     kind: .tokenReissue(.init(asset: asset, balance: balance)),
                     timestamp: Date(milliseconds: timestamp), totalFee: feeBalance, height: height)
    }
}


// MARK: BurnTransaction

extension DomainLayer.DTO.BurnTransaction {

    func transaction(by accountAddress: String,
                     assets: [String: DomainLayer.DTO.Asset]) -> DomainLayer.DTO.Transaction? {

        guard let asset = assets[self.assetId] else { return nil }
        let balance = asset.balance(self.amount)
        guard let wavesAsset = assets[Environments.Constants.wavesAssetId] else { return nil }
        let feeBalance = wavesAsset.balance(fee)

        return .init(id: id,
                     kind: .tokenBurn(.init(asset: asset, balance: balance)),
                     timestamp: Date(milliseconds: timestamp), totalFee: feeBalance, height: height)
    }
}

// MARK: ExchangeTransaction

extension DomainLayer.DTO.ExchangeTransaction {

    func transaction(by accountAddress: String,
                     assets: [String: DomainLayer.DTO.Asset],
                     accounts: [String: DomainLayer.DTO.Account]) -> DomainLayer.DTO.Transaction? {

        guard let amountAssetId = order1.assetPair.amountAsset else { return nil }
        guard let priceAssetId = order1.assetPair.priceAsset else { return nil }
        guard let wavesAsset = assets[Environments.Constants.wavesAssetId] else { return nil }
        guard let amountAsset = assets[amountAssetId] else { return nil }
        guard let priceAsset = assets[priceAssetId] else { return nil }
        let assetPair = DomainLayer.DTO.AssetPair(amountAsset: amountAsset,
                                                  priceAsset: priceAsset)

        let amount = assetPair.amountBalance(self.amount)
        let price = assetPair.priceBalance(self.price)
        let total = assetPair.totalBalance(priceAmount: self.amount,
                                           assetAmount: self.price)

        let buyMatcherFee = wavesAsset.balance(self.buyMatcherFee)
        let sellMatcherFee = wavesAsset.balance(self.sellMatcherFee)

        guard let order1 = order1.exchangeOrder(assetPair: assetPair,
                                                         accounts: accounts) else { return nil }
        guard let order2 = order2.exchangeOrder(assetPair: assetPair,
                                                         accounts: accounts) else { return nil }

         let kind: DomainLayer.DTO.Transaction.Kind = .exchange(.init(price: price,
                               amount: amount,
                               total: total,
                               buyMatcherFee: buyMatcherFee,
                               sellMatcherFee: sellMatcherFee,
                               order1: order1,
                               order2: order2))

        let feeBalance = wavesAsset.balance(fee)
        
        return .init(id: id,
                     kind: kind,
                     timestamp: Date(milliseconds: timestamp), totalFee: feeBalance, height: height)
    }
}

// MARK: LeaseTransaction

extension DomainLayer.DTO.LeaseTransaction {

    func transaction(by accountAddress: String,
                     assets: [String: DomainLayer.DTO.Asset],
                     accounts: [String: DomainLayer.DTO.Account]) -> DomainLayer.DTO.Transaction? {

        guard let wavesAsset = assets[Environments.Constants.wavesAssetId] else { return nil }
        let balance = wavesAsset.balance(self.amount)
        let isSenderAccount = sender.isMyAccount(accountAddress)

        var kind: DomainLayer.DTO.Transaction.Kind!

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

        return .init(id: id,
                     kind: kind,
                     timestamp: Date(milliseconds: timestamp), totalFee: feeBalance, height: height)
    }
}

// MARK: LeaseCancelTransaction

extension DomainLayer.DTO.LeaseCancelTransaction {

    func transaction(by accountAddress: String,
                     assets: [String: DomainLayer.DTO.Asset],
                     accounts: [String: DomainLayer.DTO.Account]) -> DomainLayer.DTO.Transaction? {

        guard let lease = self.lease else { return nil }
        guard let wavesAsset = assets[Environments.Constants.wavesAssetId] else { return nil }
        guard let recipient = accounts[lease.recipient] else { return nil }
        let balance = wavesAsset.balance(lease.amount)

        let kind: DomainLayer.DTO.Transaction.Kind = .canceledLeasing(.init(asset: wavesAsset,
                                      balance: balance,
                                      account: recipient))

        let feeBalance = wavesAsset.balance(fee)

        return .init(id: id,
                     kind: kind,
                     timestamp: Date(milliseconds: timestamp), totalFee: feeBalance, height: height)
    }
}

// MARK: AliasTransaction

extension DomainLayer.DTO.AliasTransaction {

    func transaction(by accountAddress: String, assets: [String: DomainLayer.DTO.Asset]) -> DomainLayer.DTO.Transaction? {

        let kind: DomainLayer.DTO.Transaction.Kind = .createdAlias(alias)
        guard let wavesAsset = assets[Environments.Constants.wavesAssetId] else { return nil }
        let feeBalance = wavesAsset.balance(fee)

        return .init(id: id,
                     kind: kind,
                     timestamp: Date(milliseconds: timestamp), totalFee: feeBalance, height: height)
    }
}

// MARK: MassTransferTransaction

extension DomainLayer.DTO.MassTransferTransaction {

    func transaction(by accountAddress: String,
                     assets: [String: DomainLayer.DTO.Asset],
                     accounts: [String: DomainLayer.DTO.Account]) -> DomainLayer.DTO.Transaction? {

        guard let assetId = self.assetId else { return nil }
        guard let asset = assets[assetId] else { return nil }

        let totalBalance = asset.balance(self.totalAmount)

        let transfers = self.transfers.map { tx -> DomainLayer.DTO.Transaction.MassTransfer.Transfer? in
            guard let recipient = accounts[tx.recipient] else { return nil }
            let amount = asset.money(tx.amount)
            return .init(amount: amount, recipient: recipient)
            }
            .compactMap { $0 }

        let massTransfer: DomainLayer.DTO.Transaction.MassTransfer = .init(total: totalBalance,
                                                                           asset: asset,
                                                                           transfers: transfers)
        let isSenderAccount = self.sender.isMyAccount(accountAddress)

        var kind: DomainLayer.DTO.Transaction.Kind!

        if isSenderAccount {
            kind = .massSent(massTransfer)
        } else {
            if asset.isSpam {
                kind = .spamMassReceived(massTransfer)
            } else {
                kind = .massReceived(massTransfer)
            }
        }

        guard let wavesAsset = assets[Environments.Constants.wavesAssetId] else { return nil }
        let feeBalance = wavesAsset.balance(fee)

        return .init(id: id,
                     kind: kind,
                     timestamp: Date(milliseconds: timestamp), totalFee: feeBalance, height: height)
    }
}

// MARK: DataTransaction

extension DomainLayer.DTO.DataTransaction {

    func transaction(by accountAddress: String,
                     assets: [String: DomainLayer.DTO.Asset]) -> DomainLayer.DTO.Transaction? {

        let list = data.map { data -> [String: String] in
            var map = [String: String]()
            map["key"] = data.key
            map["type"] = data.type
            map["value"] = data.value.toString
            return map
        }

        let prettyJSON = list.prettyJSON ?? ""
        let kind: DomainLayer.DTO.Transaction.Kind = .data(.init(prettyJSON: prettyJSON))

        guard let wavesAsset = assets[Environments.Constants.wavesAssetId] else { return nil }
        let feeBalance = wavesAsset.balance(fee)

        return .init(id: id,
                     kind: kind,
                     timestamp: Date(milliseconds: timestamp), totalFee: feeBalance, height: height)
    }
}

extension DomainLayer.DTO.AnyTransaction {

    func transaction(by accountAddress: String,
                     assets: [String: DomainLayer.DTO.Asset],
                     accounts: [String: DomainLayer.DTO.Account]) -> DomainLayer.DTO.Transaction? {

        switch self {

        case .unrecognised(let tx):
            return tx.transaction(by: accountAddress, assets: assets)

        case .issue(let tx):
            return tx.transaction(by: accountAddress, assets: assets)

        case .transfer(let tx):
            return tx.transaction(by: accountAddress, assets: assets, accounts: accounts)

        case .reissue(let tx):
            return tx.transaction(by: accountAddress, assets: assets)

        case .burn(let tx):
            return tx.transaction(by: accountAddress, assets: assets)

        case .exchange(let tx):
            return tx.transaction(by: accountAddress, assets: assets, accounts: accounts)

        case .lease(let tx):
            return tx.transaction(by: accountAddress, assets: assets, accounts: accounts)

        case .leaseCancel(let tx):
            return tx.transaction(by: accountAddress, assets: assets, accounts: accounts)

        case .alias(let tx):
            return tx.transaction(by: accountAddress, assets: assets)

        case .massTransfer(let tx):
            return tx.transaction(by: accountAddress, assets: assets, accounts: accounts)

        case .data(let tx):
            return tx.transaction(by: accountAddress, assets: assets)
        }
    }
}

fileprivate extension String {

    func isMyAccount(_ account: String) -> Bool {
        return self == account
    }
}

extension DomainLayer.DTO.ExchangeTransaction.Order {

    func exchangeOrder(assetPair: DomainLayer.DTO.AssetPair,
                       accounts: [String: DomainLayer.DTO.Account]) -> DomainLayer.DTO.Transaction.Exchange.Order? {

        guard let sender = accounts[self.sender] else { return nil }
        let kind: DomainLayer.DTO.Transaction.Exchange.Order.Kind = orderType == .sell ? .sell : .buy
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
