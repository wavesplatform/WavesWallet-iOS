//
//  ExchangeOrder+Assisstants.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 08/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Base58
import WavesSDKExtension
import WavesSDKCrypto

fileprivate enum TransactionDirection {
    case sent
    case selfSent
    case receive

    init(sender: DomainLayer.DTO.Address,
         recipient: DomainLayer.DTO.Address) {

        if sender.isMyAccount && recipient.isMyAccount {
            self = .selfSent
        } else if sender.isMyAccount {
            self = .sent
        } else {
            self = .receive
        }
    }
}

private enum Constants {
    static let key = "key"
    static let type = "type"
    static let value = "value"
}

// MARK: UnrecognisedTransaction

extension Int64 {

    func confirmationHeight(txHeight: Int64?) -> Int64 {
        //NotFound
        guard let txHeight = txHeight else { return -1 }
        return self - txHeight
    }
}

struct SmartTransactionMetaData {
    let account: DomainLayer.DTO.Address
    let assets: [String: DomainLayer.DTO.Asset]
    let accounts: [String: DomainLayer.DTO.Address]
    let totalHeight: Int64
    let status: DomainLayer.DTO.SmartTransaction.Status
    let mapTxs: [String: DomainLayer.DTO.AnyTransaction]
}

private func decodedString(_ string: String?) -> String? {
    
    if let string = string {
        return Base58.decodeToStr(string)
    }
    return nil
}

extension DomainLayer.DTO.UnrecognisedTransaction {

    func transaction(by metaData: SmartTransactionMetaData) -> DomainLayer.DTO.SmartTransaction? {

        let assets: [String: DomainLayer.DTO.Asset] = metaData.assets
        let accounts: [String: DomainLayer.DTO.Address] = metaData.accounts
        let totalHeight: Int64 = metaData.totalHeight

        guard let wavesAsset = assets[WavesSDKCryptoConstants.wavesAssetId] else {
            return nil
        }
        guard let sender = accounts[self.sender] else {
            return nil
        }

        let feeBalance = wavesAsset.balance(fee)

        return .init(id: id,
                     type: type,
                     kind: .unrecognisedTransaction,
                     timestamp: timestamp,
                     totalFee: feeBalance,
                     feeAsset: wavesAsset,
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
        let accounts: [String: DomainLayer.DTO.Address] = metaData.accounts
        let totalHeight: Int64 = metaData.totalHeight

        guard let wavesAsset = assets[WavesSDKCryptoConstants.wavesAssetId] else {
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
                     type: type,
                     kind: .tokenGeneration(.init(asset: asset, balance: balance, description: nil)),
                     timestamp: timestamp,
                     totalFee: feeBalance,
                     feeAsset: wavesAsset,
                     height: height,
                     confirmationHeight: totalHeight.confirmationHeight(txHeight: height),
                     sender: sender,
                     status: metaData.status)
    }
}

// MARK: TransferTransaction

extension DomainLayer.DTO.TransferTransaction {

    func transaction(by metaData: SmartTransactionMetaData) -> DomainLayer.DTO.SmartTransaction? {

        let assets: [String: DomainLayer.DTO.Asset] = metaData.assets
        let accounts: [String: DomainLayer.DTO.Address] = metaData.accounts
        let totalHeight: Int64 = metaData.totalHeight

        let assetId = self.assetId
        guard let asset = assets[assetId] else {
            SweetLogger.error("TransferTransaction Not found Asset ID")
            return nil
        }

        guard let feeAsset = assets[feeAssetId] else {
            SweetLogger.error("TransferTransaction Not found Fee Asset ID")
            return nil
        }
        guard let recipient = accounts[self.recipient] else {
            SweetLogger.error("TransferTransaction Not found Recipient ID")
            return nil
        }
        guard let sender = accounts[self.sender] else {
            SweetLogger.error("TransferTransaction Not found Sender ID")
            return nil
        }

        let externalAccounts = [recipient.address, sender.address]

        let hasMyAccount = externalAccounts.contains(metaData.account.address)
        let hasMyAliases = metaData.account.aliases.contains(where: { (alias) -> Bool in
            return externalAccounts.contains(alias.name)
        })

        let transactionDirection = TransactionDirection(sender: sender,
                                                        recipient: recipient)

        let hasSponsorship = (hasMyAccount == false && hasMyAliases == false) && transactionDirection == .receive

        var transferBalance = asset.balance(self.amount)
        var transferAsset = asset

        if hasSponsorship {
            transferBalance = feeAsset.balance(self.fee)
            transferAsset = feeAsset
        }

        let transfer: DomainLayer.DTO.SmartTransaction.Transfer = .init(balance: transferBalance,
                                                                        asset: transferAsset,
                                                                        recipient: transactionDirection == .receive ? sender : recipient,
                                                                        attachment: decodedString(attachment),
                                                                        hasSponsorship: hasSponsorship)


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

        guard let wavesAsset = assets[WavesSDKCryptoConstants.wavesAssetId] else {
            SweetLogger.error("TransferTransaction Not found Waves ID")
            return nil
        }

        let feeBalance: Balance = feeAsset.balance(fee)

        return .init(id: id,
                     type: type,
                     kind: kind,
                     timestamp: timestamp,
                     totalFee: feeBalance,
                     feeAsset: feeAsset,
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
        let accounts: [String: DomainLayer.DTO.Address] = metaData.accounts
        let totalHeight: Int64 = metaData.totalHeight

        guard let asset = assets[self.assetId] else {
            return nil
        }
        guard let sender = accounts[self.sender] else {
            return nil
        }
        guard let wavesAsset = assets[WavesSDKCryptoConstants.wavesAssetId] else {
            return nil
        }

        let balance = asset.balance(self.quantity)
        let feeBalance = wavesAsset.balance(fee)

        return .init(id: id,
                     type: type,
                     kind: .tokenReissue(.init(asset: asset,
                                               balance: balance,
                                               description: nil)),
                     timestamp: timestamp,
                     totalFee: feeBalance,
                     feeAsset: wavesAsset,
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
        let accounts: [String: DomainLayer.DTO.Address] = metaData.accounts
        let totalHeight: Int64 = metaData.totalHeight

        guard let asset = assets[self.assetId] else {
            SweetLogger.error("MassTransferTransaction Not found Asset ID")
            return nil
        }
        guard let sender = accounts[self.sender] else {
            SweetLogger.error("MassTransferTransaction Not found Sender ID")
            return nil
        }
        guard let wavesAsset = assets[WavesSDKCryptoConstants.wavesAssetId] else {
            SweetLogger.error("MassTransferTransaction Not found Waves ID")
            return nil
        }
        let balance = asset.balance(self.amount)
        let feeBalance = wavesAsset.balance(fee)

        return .init(id: id,
                     type: type,
                     kind: .tokenBurn(.init(asset: asset,
                                            balance: balance,
                                            description: nil)),
                     timestamp: timestamp,
                     totalFee: feeBalance,
                     feeAsset: wavesAsset,
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
        let accounts: [String: DomainLayer.DTO.Address] = metaData.accounts
        let totalHeight: Int64 = metaData.totalHeight

        let amountAssetId = order1.assetPair.amountAsset
        let priceAssetId = order1.assetPair.priceAsset
        guard let wavesAsset = assets[WavesSDKCryptoConstants.wavesAssetId] else {
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
                     type: type,
                     kind: kind,
                     timestamp: timestamp,
                     totalFee: feeBalance,
                     feeAsset: wavesAsset,
                     height: height,
                     confirmationHeight: totalHeight.confirmationHeight(txHeight: height),
                     sender: sender,
                     status: metaData.status)
    }
}

// MARK: LeaseTransaction

extension DomainLayer.DTO.LeaseTransaction {

    func transaction(by metaData: SmartTransactionMetaData) -> DomainLayer.DTO.SmartTransaction? {

        let accountAddress: String = metaData.account.address
        let assets: [String: DomainLayer.DTO.Asset] = metaData.assets
        let accounts: [String: DomainLayer.DTO.Address] = metaData.accounts
        let totalHeight: Int64 = metaData.totalHeight

        guard let wavesAsset = assets[WavesSDKCryptoConstants.wavesAssetId] else { return nil }
        let balance = wavesAsset.balance(self.amount)
        let isSenderAccount = sender.isMyAccount(accountAddress)

        var kind: DomainLayer.DTO.SmartTransaction.Kind!

        if isSenderAccount {
            guard let recipient = accounts[self.recipient] else { return nil }
            kind = .startedLeasing(.init(asset: wavesAsset,
                                         balance: balance,
                                         account: recipient,
                                         myAccount: metaData.account))
        } else {
            guard let sender = accounts[self.sender] else { return nil }
            kind = .incomingLeasing(.init(asset: wavesAsset,
                                          balance: balance,
                                          account: sender,
                                          myAccount: metaData.account))
        }

        let feeBalance = wavesAsset.balance(fee)

        guard let sender = accounts[self.sender] else { return nil }

        return .init(id: id,
                     type: type,
                     kind: kind,
                     timestamp: timestamp,
                     totalFee: feeBalance,
                     feeAsset: wavesAsset,
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
        let accounts: [String: DomainLayer.DTO.Address] = metaData.accounts
        let totalHeight: Int64 = metaData.totalHeight

        let optionalLease = self.lease

        guard let lease = optionalLease else {
            return nil
        }

        guard let wavesAsset = assets[WavesSDKCryptoConstants.wavesAssetId] else {

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
                                                                                 account: recipient,
                                                                                 myAccount: metaData.account))

        let feeBalance = wavesAsset.balance(fee)

        return .init(id: id,
                     type: type,
                     kind: kind,
                     timestamp: timestamp,
                     totalFee: feeBalance,
                     feeAsset: wavesAsset,
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
        let accounts: [String: DomainLayer.DTO.Address] = metaData.accounts
        let totalHeight: Int64 = metaData.totalHeight

        guard let wavesAsset = assets[WavesSDKCryptoConstants.wavesAssetId] else { return nil }
        guard let sender = accounts[self.sender] else { return nil }

        let kind: DomainLayer.DTO.SmartTransaction.Kind = .createdAlias(alias)
        let feeBalance = wavesAsset.balance(fee)
        
        return .init(id: id,
                     type: type,
                     kind: kind,
                     timestamp: timestamp,
                     totalFee: feeBalance,
                     feeAsset: wavesAsset,
                     height: height,
                     confirmationHeight: totalHeight.confirmationHeight(txHeight: height),
                     sender: sender,
                     status: metaData.status)
    }
}

// MARK: ScriptTransaction

extension DomainLayer.DTO.ScriptTransaction {

    func transaction(by metaData: SmartTransactionMetaData) -> DomainLayer.DTO.SmartTransaction? {

        let assets: [String: DomainLayer.DTO.Asset] = metaData.assets
        let accounts: [String: DomainLayer.DTO.Address] = metaData.accounts
        let totalHeight: Int64 = metaData.totalHeight

        guard let wavesAsset = assets[WavesSDKCryptoConstants.wavesAssetId] else { return nil }
        guard let sender = accounts[self.sender] else { return nil }

        let kind: DomainLayer.DTO.SmartTransaction.Kind = .script(isHasScript: script != nil)
        let feeBalance = wavesAsset.balance(fee)

        return .init(id: id,
                     type: type,
                     kind: kind,
                     timestamp: timestamp,
                     totalFee: feeBalance,
                     feeAsset: wavesAsset,
                     height: height,
                     confirmationHeight: totalHeight.confirmationHeight(txHeight: height),
                     sender: sender,
                     status: metaData.status)
    }
}

// MARK: AssetScriptTransaction

extension DomainLayer.DTO.AssetScriptTransaction {

    func transaction(by metaData: SmartTransactionMetaData) -> DomainLayer.DTO.SmartTransaction? {

        let assets: [String: DomainLayer.DTO.Asset] = metaData.assets
        let accounts: [String: DomainLayer.DTO.Address] = metaData.accounts
        let totalHeight: Int64 = metaData.totalHeight

        guard let wavesAsset = assets[WavesSDKCryptoConstants.wavesAssetId] else { return nil }
        guard let assetId = assets[assetId] else { return nil }
        guard let sender = accounts[self.sender] else { return nil }

        let kind: DomainLayer.DTO.SmartTransaction.Kind = .assetScript(assetId)
        let feeBalance = wavesAsset.balance(fee)

        return .init(id: id,
                     type: type,
                     kind: kind,
                     timestamp: timestamp,
                     totalFee: feeBalance,
                     feeAsset: wavesAsset,
                     height: height,
                     confirmationHeight: totalHeight.confirmationHeight(txHeight: height),
                     sender: sender,
                     status: metaData.status)
    }
}

// MARK: SponsorshipTransaction

extension DomainLayer.DTO.SponsorshipTransaction {

    func transaction(by metaData: SmartTransactionMetaData) -> DomainLayer.DTO.SmartTransaction? {

        let assets: [String: DomainLayer.DTO.Asset] = metaData.assets
        let accounts: [String: DomainLayer.DTO.Address] = metaData.accounts
        let totalHeight: Int64 = metaData.totalHeight

        guard let wavesAsset = assets[WavesSDKCryptoConstants.wavesAssetId] else { return nil }
        guard let assetAccount = assets[assetId] else { return nil }
        guard let sender = accounts[self.sender] else { return nil }

        let isEnabled = self.minSponsoredAssetFee != nil
        
        let kind: DomainLayer.DTO.SmartTransaction.Kind = .sponsorship(isEnabled: isEnabled, asset: assetAccount)
        let feeBalance = wavesAsset.balance(fee)

        return .init(id: id,
                     type: type,
                     kind: kind,
                     timestamp: timestamp,
                     totalFee: feeBalance,
                     feeAsset: wavesAsset,
                     height: height,
                     confirmationHeight: totalHeight.confirmationHeight(txHeight: height),
                     sender: sender,
                     status: metaData.status)
    }
}

// MARK: MassTransferTransaction

extension DomainLayer.DTO.MassTransferTransaction {

    func transaction(by metaData: SmartTransactionMetaData) -> DomainLayer.DTO.SmartTransaction? {

        let assets: [String: DomainLayer.DTO.Asset] = metaData.assets
        let accounts: [String: DomainLayer.DTO.Address] = metaData.accounts
        let totalHeight: Int64 = metaData.totalHeight

        let assetId = self.assetId
        guard let asset = assets[assetId] else {
            SweetLogger.error("MassTransferTransaction Not found assetId")
            return nil

        }
        guard let sender = accounts[self.sender] else {
            SweetLogger.error("MassTransferTransaction not found sender")
            return nil
        }

        let totalBalance = asset.balance(self.totalAmount)

        let isSenderAccount = sender.isMyAccount

        var kind: DomainLayer.DTO.SmartTransaction.Kind!

        if isSenderAccount {
            let transfers = self.transfers.map { tx -> DomainLayer.DTO.SmartTransaction.MassTransfer.Transfer? in
                guard let recipient = accounts[tx.recipient] else {
                    SweetLogger.error("MassTransferTransaction Not found recipient")
                    return nil
                }
                let amount = asset.money(tx.amount)
                return .init(amount: amount, recipient: recipient)
            }
            .compactMap { $0 }

            let massTransfer: DomainLayer.DTO.SmartTransaction.MassTransfer = .init(total: totalBalance,
                                                                                    asset: asset,
                                                                                    attachment: decodedString(attachment),
                                                                                    transfers: transfers)
            kind = .massSent(massTransfer)
        } else {

            let transfers = self.transfers.map { tx -> DomainLayer.DTO.SmartTransaction.MassReceive.Transfer? in
                guard accounts[tx.recipient] != nil else {
                    SweetLogger.error("MassTransferTransaction Not found recipient")
                    return nil
                }
                let amount = asset.money(tx.amount)
                return .init(amount: amount, recipient: sender)
            }
            .compactMap { $0 }

            let myTotalAmount: Int64 = transfers.reduce(into: Int64(0), { (result, transfer) in
                
                if !transfer.recipient.isMyAccount {
                    result += transfer.amount.amount
                }
            })

            let myTotalBalance = asset.balance(myTotalAmount)

            let massReceive: DomainLayer.DTO.SmartTransaction.MassReceive = .init(total: totalBalance,
                                                                                  myTotal: myTotalBalance,
                                                                                  asset: asset,
                                                                                  attachment: decodedString(attachment),
                                                                                  transfers: transfers)
            if asset.isSpam {
                kind = .spamMassReceived(massReceive)
            } else {
                kind = .massReceived(massReceive)
            }
        }

        guard let wavesAsset = assets[WavesSDKCryptoConstants.wavesAssetId] else {
            SweetLogger.error("MassTransferTransaction Not found Waves ID")
            return nil
        }
        let feeBalance = wavesAsset.balance(fee)

        return .init(id: id,
                     type: type,
                     kind: kind,
                     timestamp: timestamp,
                     totalFee: feeBalance,
                     feeAsset: wavesAsset,
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
        let accounts: [String: DomainLayer.DTO.Address] = metaData.accounts
        let totalHeight: Int64 = metaData.totalHeight

        let list = data.map { data -> [String: String] in
            var map = [String: String]()
            map[Constants.key] = data.key
            map[Constants.type] = data.type
            map[Constants.value] = data.value.toString
            return map
        }

        let prettyJSON = list.prettyJSON ?? ""
        let kind: DomainLayer.DTO.SmartTransaction.Kind = .data(.init(prettyJSON: prettyJSON))

        guard let wavesAsset = assets[WavesSDKCryptoConstants.wavesAssetId] else { return nil }
        guard let sender = accounts[self.sender] else { return nil }
        let feeBalance = wavesAsset.balance(fee)

        return .init(id: id,
                     type: type,
                     kind: kind,
                     timestamp: timestamp,
                     totalFee: feeBalance,
                     feeAsset: wavesAsset,
                     height: height,
                     confirmationHeight: totalHeight.confirmationHeight(txHeight: height),
                     sender: sender,
                     status: metaData.status)
    }
}

// MARK: AnyTransaction

extension DomainLayer.DTO.AnyTransaction {

    func transaction(by accountAddress: String,
                     assets: [String: DomainLayer.DTO.Asset],
                     accounts: [String: DomainLayer.DTO.Address],
                     totalHeight: Int64,
                     leaseTransactions: [String: DomainLayer.DTO.LeaseTransaction],
                     mapTxs: [String: DomainLayer.DTO.AnyTransaction]) -> DomainLayer.DTO.SmartTransaction? {


        guard let account = accounts[accountAddress] else {
            SweetLogger.debug("account Not Found \(self)")
            return nil
        }

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

        let smartData = SmartTransactionMetaData(account: account,
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

        case .script(let tx):
            smartTransaction = tx.transaction(by: smartData)

        case .assetScript(let tx):
            smartTransaction = tx.transaction(by: smartData)

        case .sponsorship(let tx):
            smartTransaction = tx.transaction(by: smartData)
        }

        if smartTransaction == nil {
           SweetLogger.debug("Not Found TX \(self)")
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
                       accounts: [String: DomainLayer.DTO.Address]) -> DomainLayer.DTO.SmartTransaction.Exchange.Order? {

        guard let sender = accounts[self.sender] else { return nil }
        let kind: DomainLayer.DTO.SmartTransaction.Exchange.Order.Kind = orderType == .sell ? .sell : .buy
        let amount = assetPair.amountBalance(self.amount)
        let price = assetPair.priceBalance(self.price)
        //TODO: Is Correct?не
        let total = assetPair.totalBalance(priceAmount: self.amount,
                                           assetAmount: self.price)

        return .init(timestamp: timestamp,
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
