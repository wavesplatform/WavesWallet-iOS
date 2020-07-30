//
//  ExchangeOrder+Assisstants.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 08/09/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Extensions
import Foundation
import WavesSDK
import WavesSDKCrypto
import WavesSDKExtensions

fileprivate enum TransactionDirection {
    case sent
    case selfSent
    case receive

    init(sender: Address,
         recipient: Address) {
        if sender.isMyAccount, recipient.isMyAccount {
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

//TODO: Remove from Int64
extension Int64 {
    func confirmationHeight(txHeight: Int64?) -> Int64 {
        
        guard let txHeight = txHeight else { return -1 }
        return self - txHeight
    }
}

struct SmartTransactionMetaData {
    let account: Address
    let assets: [String: Asset]
    let accounts: [String: Address]
    let totalHeight: Int64
    let status: SmartTransaction.Status
    let mapTxs: [String: AnyTransaction]
}

private func decodedString(_ string: String?) -> String? {
    if let string = string {
        return Base58Encoder.decodeToStr(string)
    }
    return nil
}

extension UnrecognisedTransaction {
    func transaction(by metaData: SmartTransactionMetaData) -> SmartTransaction? {
        let assets: [String: Asset] = metaData.assets
        let accounts: [String: Address] = metaData.accounts
        let totalHeight: Int64 = metaData.totalHeight

        guard let wavesAsset = assets[WavesSDKConstants.wavesAssetId] else {
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

extension IssueTransaction {
    func transaction(by metaData: SmartTransactionMetaData) -> SmartTransaction? {
        let assets: [String: Asset] = metaData.assets
        let accounts: [String: Address] = metaData.accounts
        let totalHeight: Int64 = metaData.totalHeight

        guard let wavesAsset = assets[WavesSDKConstants.wavesAssetId] else {
            return nil
        }
        guard let sender = accounts[self.sender] else {
            return nil
        }
        guard let asset = assets[assetId] else {
            return nil
        }
        let balance = asset.balance(quantity)
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

extension TransferTransaction {
    func transaction(by metaData: SmartTransactionMetaData) -> SmartTransaction? {
        let assets: [String: Asset] = metaData.assets
        let accounts: [String: Address] = metaData.accounts
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
            externalAccounts.contains(alias.name)
        })

        let transactionDirection = TransactionDirection(sender: sender,
                                                        recipient: recipient)

        let hasSponsorship = (hasMyAccount == false && hasMyAliases == false) && transactionDirection == .receive

        var transferBalance = asset.balance(amount)
        var transferAsset = asset

        if hasSponsorship {
            transferBalance = feeAsset.balance(fee)
            transferAsset = feeAsset
        }

        let transfer: SmartTransaction.Transfer = .init(balance: transferBalance,
                                                        asset: transferAsset,
                                                        recipient: transactionDirection == .receive ? sender : recipient,
                                                        attachment: decodedString(attachment),
                                                        hasSponsorship: hasSponsorship,
                                                        myAccount: metaData.account)

        var kind: SmartTransaction.Kind!

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

        guard assets[WavesSDKConstants.wavesAssetId] != nil else {
            SweetLogger.error("TransferTransaction Not found Waves ID")
            return nil
        }

        let feeBalance: DomainLayer.DTO.Balance = feeAsset.balance(fee)

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

extension ReissueTransaction {
    func transaction(by metaData: SmartTransactionMetaData) -> SmartTransaction? {
        let assets: [String: Asset] = metaData.assets
        let accounts: [String: Address] = metaData.accounts
        let totalHeight: Int64 = metaData.totalHeight

        guard let asset = assets[assetId] else {
            return nil
        }
        guard let sender = accounts[self.sender] else {
            return nil
        }
        guard let wavesAsset = assets[WavesSDKConstants.wavesAssetId] else {
            return nil
        }

        let balance = asset.balance(quantity)
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

extension BurnTransaction {
    func transaction(by metaData: SmartTransactionMetaData) -> SmartTransaction? {
        let assets: [String: Asset] = metaData.assets
        let accounts: [String: Address] = metaData.accounts
        let totalHeight: Int64 = metaData.totalHeight

        guard let asset = assets[assetId] else {
            SweetLogger.error("MassTransferTransaction Not found Asset ID")
            return nil
        }
        guard let sender = accounts[self.sender] else {
            SweetLogger.error("MassTransferTransaction Not found Sender ID")
            return nil
        }
        guard let wavesAsset = assets[WavesSDKConstants.wavesAssetId] else {
            SweetLogger.error("MassTransferTransaction Not found Waves ID")
            return nil
        }
        let balance = asset.balance(amount)
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

extension ExchangeTransaction {
    func transaction(by metaData: SmartTransactionMetaData) -> SmartTransaction? {
        let assets: [String: Asset] = metaData.assets
        let accounts: [String: Address] = metaData.accounts
        let totalHeight: Int64 = metaData.totalHeight

        let amountAssetId = order1.assetPair.amountAsset
        let priceAssetId = order1.assetPair.priceAsset
        guard let wavesAsset = assets[WavesSDKConstants.wavesAssetId] else {
            return nil
        }
        guard let amountAsset = assets[amountAssetId] else {
            return nil
        }
        guard let priceAsset = assets[priceAssetId] else {
            return nil
        }

        let assetPair = AssetPair(amountAsset: amountAsset,
                                  priceAsset: priceAsset)

        let amount = assetPair.amountBalance(self.amount)
        let price = assetPair.priceBalance(self.price)
        let total = assetPair.totalBalance(priceAmount: self.price,
                                           assetAmount: self.amount)

        var buyMatcherFee: DomainLayer.DTO.Balance!
        var sellMatcherFee: DomainLayer.DTO.Balance!

        if let matcherFeeAssetId = order1.matcherFeeAssetId {
            guard let matcherFeeAsset = assets[matcherFeeAssetId] else { return nil }

            if order1.orderType == .sell {
                sellMatcherFee = matcherFeeAsset.balance(self.sellMatcherFee)
            } else {
                buyMatcherFee = matcherFeeAsset.balance(self.buyMatcherFee)
            }
        }

        if let matcherFeeAssetId = order2.matcherFeeAssetId {
            guard let matcherFeeAsset = assets[matcherFeeAssetId] else { return nil }

            if order2.orderType == .sell {
                sellMatcherFee = matcherFeeAsset.balance(self.sellMatcherFee)
            } else {
                buyMatcherFee = matcherFeeAsset.balance(self.buyMatcherFee)
            }
        }

        if buyMatcherFee == nil {
            buyMatcherFee = wavesAsset.balance(self.buyMatcherFee)
        }

        if sellMatcherFee == nil {
            sellMatcherFee = wavesAsset.balance(self.sellMatcherFee)
        }

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

        let kind: SmartTransaction.Kind = .exchange(.init(price: price,
                                                          amount: amount,
                                                          total: total,
                                                          buyMatcherFee: buyMatcherFee,
                                                          sellMatcherFee: sellMatcherFee,
                                                          order1: order1,
                                                          order2: order2))

        // TODO: Проверить комиссию для одного sendera
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

extension LeaseTransaction {
    func transaction(by metaData: SmartTransactionMetaData) -> SmartTransaction? {
        let accountAddress: String = metaData.account.address
        let assets: [String: Asset] = metaData.assets
        let accounts: [String: Address] = metaData.accounts
        let totalHeight: Int64 = metaData.totalHeight

        guard let wavesAsset = assets[WavesSDKConstants.wavesAssetId] else { return nil }
        let balance = wavesAsset.balance(amount)
        let isSenderAccount = sender.isMyAccount(accountAddress)

        var kind: SmartTransaction.Kind!

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

extension LeaseCancelTransaction {
    func transaction(by metaData: SmartTransactionMetaData) -> SmartTransaction? {
        let assets: [String: Asset] = metaData.assets
        let accounts: [String: Address] = metaData.accounts
        let totalHeight: Int64 = metaData.totalHeight

        let optionalLease = self.lease

        guard let lease = optionalLease else {
            return nil
        }

        guard let wavesAsset = assets[WavesSDKConstants.wavesAssetId] else {
            return nil
        }
        guard let recipient = accounts[lease.recipient] else {
            return nil
        }
        guard let sender = accounts[self.sender] else {
            return nil
        }

        let balance = wavesAsset.balance(lease.amount)

        let kind: SmartTransaction.Kind = .canceledLeasing(.init(asset: wavesAsset,
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

extension AliasTransaction {
    func transaction(by metaData: SmartTransactionMetaData) -> SmartTransaction? {
        let assets: [String: Asset] = metaData.assets
        let accounts: [String: Address] = metaData.accounts
        let totalHeight: Int64 = metaData.totalHeight

        guard let wavesAsset = assets[WavesSDKConstants.wavesAssetId] else { return nil }
        guard let sender = accounts[self.sender] else { return nil }

        let kind: SmartTransaction.Kind = .createdAlias(alias)
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

extension ScriptTransaction {
    func transaction(by metaData: SmartTransactionMetaData) -> SmartTransaction? {
        let assets: [String: Asset] = metaData.assets
        let accounts: [String: Address] = metaData.accounts
        let totalHeight: Int64 = metaData.totalHeight

        guard let wavesAsset = assets[WavesSDKConstants.wavesAssetId] else { return nil }
        guard let sender = accounts[self.sender] else { return nil }

        let kind: SmartTransaction.Kind = .script(isHasScript: script != nil)
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

extension AssetScriptTransaction {
    func transaction(by metaData: SmartTransactionMetaData) -> SmartTransaction? {
        let assets: [String: Asset] = metaData.assets
        let accounts: [String: Address] = metaData.accounts
        let totalHeight: Int64 = metaData.totalHeight

        guard let wavesAsset = assets[WavesSDKConstants.wavesAssetId] else { return nil }
        guard let assetId = assets[assetId] else { return nil }
        guard let sender = accounts[self.sender] else { return nil }

        let kind: SmartTransaction.Kind = .assetScript(assetId)
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

extension SponsorshipTransaction {
    func transaction(by metaData: SmartTransactionMetaData) -> SmartTransaction? {
        let assets: [String: Asset] = metaData.assets
        let accounts: [String: Address] = metaData.accounts
        let totalHeight: Int64 = metaData.totalHeight

        guard let wavesAsset = assets[WavesSDKConstants.wavesAssetId] else { return nil }
        guard let assetAccount = assets[assetId] else { return nil }
        guard let sender = accounts[self.sender] else { return nil }

        let isEnabled = minSponsoredAssetFee != nil

        let kind: SmartTransaction.Kind = .sponsorship(isEnabled: isEnabled, asset: assetAccount)
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

extension MassTransferTransaction {
    func transaction(by metaData: SmartTransactionMetaData) -> SmartTransaction? {
        let assets: [String: Asset] = metaData.assets
        let accounts: [String: Address] = metaData.accounts
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

        let totalBalance = asset.balance(totalAmount)

        let isSenderAccount = sender.isMyAccount

        var kind: SmartTransaction.Kind!

        if isSenderAccount {
            let transfers = self.transfers.map { tx -> SmartTransaction.MassTransfer.Transfer? in
                guard let recipient = accounts[tx.recipient] else {
                    SweetLogger.error("MassTransferTransaction Not found recipient")
                    return nil
                }
                let amount = asset.money(tx.amount)
                return .init(amount: amount, recipient: recipient)
            }
            .compactMap { $0 }

            let massTransfer: SmartTransaction.MassTransfer = .init(total: totalBalance,
                                                                    asset: asset,
                                                                    attachment: decodedString(attachment),
                                                                    transfers: transfers)
            kind = .massSent(massTransfer)
        } else {
            let transfers = self.transfers.map { tx -> SmartTransaction.MassReceive.Transfer? in
                guard accounts[tx.recipient] != nil else {
                    SweetLogger.error("MassTransferTransaction Not found recipient")
                    return nil
                }
                let amount = asset.money(tx.amount)
                return .init(amount: amount, recipient: sender)
            }
            .compactMap { $0 }

            let myTotalAmount: Int64 = transfers.reduce(into: Int64(0)) { result, transfer in

                if !transfer.recipient.isMyAccount {
                    result += transfer.amount.amount
                }
            }

            let myTotalBalance = asset.balance(myTotalAmount)

            let massReceive: SmartTransaction.MassReceive = .init(total: totalBalance,
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

        guard let wavesAsset = assets[WavesSDKConstants.wavesAssetId] else {
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

extension DataTransaction {
    func transaction(by metaData: SmartTransactionMetaData) -> SmartTransaction? {
        let assets: [String: Asset] = metaData.assets
        let accounts: [String: Address] = metaData.accounts
        let totalHeight: Int64 = metaData.totalHeight

        let list = data.map { data -> [String: String] in
            var map = [String: String]()
            map[Constants.key] = data.key
            map[Constants.type] = data.type
            map[Constants.value] = data.value?.toString
            return map
        }

        let prettyJSON = list.prettyJSON ?? ""
        let kind: SmartTransaction.Kind = .data(.init(prettyJSON: prettyJSON))

        guard let wavesAsset = assets[WavesSDKConstants.wavesAssetId] else { return nil }
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

// MARK: InvokeScriptTransaction

extension InvokeScriptTransaction {
    func transaction(by metaData: SmartTransactionMetaData) -> SmartTransaction? {
        let assets: [String: Asset] = metaData.assets
        let accounts: [String: Address] = metaData.accounts
        let totalHeight: Int64 = metaData.totalHeight

        guard let wavesAsset = assets[WavesSDKConstants.wavesAssetId] else { return nil }

        let smartPayments: [SmartTransaction.InvokeScript.Payment]? = payments?.map { txPayment in

            if let paymentAssetId = txPayment.assetId {
                guard let paymentAsset = assets[paymentAssetId] else { return nil }

                return SmartTransaction.InvokeScript
                    .Payment(amount: Money(txPayment.amount, paymentAsset.precision), asset: paymentAsset)
            } else {
                return SmartTransaction.InvokeScript
                .Payment(amount: Money(txPayment.amount, wavesAsset.precision), asset: wavesAsset)
            }
        }
        .compactMap { $0 }

        let feeBalance = wavesAsset.balance(fee)
        guard let sender = accounts[self.sender] else { return nil }

        return .init(id: id,
                     type: type,
                     kind: .invokeScript(SmartTransaction.InvokeScript(payments: smartPayments,
                                                                       scriptAddress: dappAddress)),
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

extension AnyTransaction {
    func transaction(by accountAddress: String,
                     assets: [String: Asset],
                     accounts: [String: Address],
                     totalHeight: Int64,
                     leaseTransactions: [String: LeaseTransaction],
                     mapTxs: [String: AnyTransaction]) -> SmartTransaction? {
        guard let account = accounts[accountAddress] else {
            SweetLogger.debug("account Not Found \(self)")
            return nil
        }

        var status: SmartTransaction.Status = .completed

        switch self.status {
        case .activeNow:
            status = .activeNow

        case .completed:
            status = .completed

        case .unconfirmed:
            status = .unconfirmed
        case .fail:
            status = .fail
        }

        if isLease, leaseTransactions[id] != nil {
            status = .activeNow
        }

        let smartData = SmartTransactionMetaData(account: account,
                                                 assets: assets,
                                                 accounts: accounts,
                                                 totalHeight: totalHeight,
                                                 status: status,
                                                 mapTxs: mapTxs)

        var smartTransaction: SmartTransaction?
        switch self {
        case let .unrecognised(tx):
            smartTransaction = tx.transaction(by: smartData)

        case let .issue(tx):
            smartTransaction = tx.transaction(by: smartData)

        case let .transfer(tx):
            smartTransaction = tx.transaction(by: smartData)

        case let .reissue(tx):
            smartTransaction = tx.transaction(by: smartData)

        case let .burn(tx):
            smartTransaction = tx.transaction(by: smartData)

        case let .exchange(tx):
            smartTransaction = tx.transaction(by: smartData)

        case let .lease(tx):
            smartTransaction = tx.transaction(by: smartData)

        case let .leaseCancel(tx):
            smartTransaction = tx.transaction(by: smartData)

        case let .alias(tx):
            smartTransaction = tx.transaction(by: smartData)

        case let .massTransfer(tx):
            smartTransaction = tx.transaction(by: smartData)

        case let .data(tx):
            smartTransaction = tx.transaction(by: smartData)

        case let .script(tx):
            smartTransaction = tx.transaction(by: smartData)

        case let .assetScript(tx):
            smartTransaction = tx.transaction(by: smartData)

        case let .sponsorship(tx):
            smartTransaction = tx.transaction(by: smartData)

        case let .invokeScript(tx):
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

extension ExchangeTransaction.Order {
    func exchangeOrder(assetPair: AssetPair,
                       accounts: [String: Address]) -> SmartTransaction.Exchange.Order? {
        guard let sender = accounts[self.sender] else { return nil }
        let kind: SmartTransaction.Exchange.Order.Kind = orderType == .sell ? .sell : .buy
        let amount = assetPair.amountBalance(self.amount)
        let price = assetPair.priceBalance(self.price)

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

fileprivate extension DataTransaction.Data.Value {
    var toString: String {
        switch self {
        case let .bool(value):
            return "\(value)"

        case let .integer(value):
            return "\(value)"

        case let .string(value):
            return "\(value)"

        case let .binary(value):
            return "\(value)"
        }
    }
}
