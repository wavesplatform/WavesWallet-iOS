//
//  AnyTransaction+Mapper.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 31/08/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import WavesSDK
import WavesSDKExtensions

extension NodeService.DTO.Transaction {
    func anyTransaction(status: TransactionStatus?,
                        scheme _: UInt8,
                        aliasScheme: String) -> AnyTransaction {
        switch self {
        case let .unrecognised(transaction):
            return .unrecognised(.init(transaction: transaction, status: status, aliasScheme: aliasScheme))

        case let .issue(transaction):
            return .issue(.init(transaction: transaction, status: status, aliasScheme: aliasScheme))

        case let .transfer(transaction):
            return .transfer(.init(transaction: transaction, status: status, aliasScheme: aliasScheme))

        case let .reissue(transaction):
            return .reissue(.init(transaction: transaction, status: status, aliasScheme: aliasScheme))

        case let .burn(transaction):
            return .burn(.init(transaction: transaction, status: status, aliasScheme: aliasScheme))

        case let .exchange(transaction):
            return .exchange(.init(transaction: transaction, status: status, aliasScheme: aliasScheme))

        case let .lease(transaction):
            return .lease(.init(transaction: transaction, status: status, aliasScheme: aliasScheme))

        case let .leaseCancel(transaction):
            return .leaseCancel(.init(transaction: transaction, status: status, aliasScheme: aliasScheme))

        case let .alias(transaction):
            return .alias(.init(transaction: transaction, status: status, aliasScheme: aliasScheme))

        case let .massTransfer(transaction):
            return .massTransfer(.init(transaction: transaction, status: status, aliasScheme: aliasScheme))

        case let .data(transaction):
            return .data(.init(transaction: transaction, status: status, aliasScheme: aliasScheme))

        case let .script(transaction):
            return .script(.init(transaction: transaction, status: status, aliasScheme: aliasScheme))

        case let .assetScript(transaction):
            return .assetScript(.init(transaction: transaction, status: status, aliasScheme: aliasScheme))

        case let .sponsorship(transaction):
            return .sponsorship(.init(transaction: transaction, status: status, aliasScheme: aliasScheme))

        case let .invokeScript(transaction):
            return .invokeScript(.init(transaction: transaction, status: status, aliasScheme: aliasScheme))

        case let .updateAssetInfo(transaction):
            return .updateAssetInfo(.init(transaction: transaction, status: status, aliasScheme: aliasScheme))
        }
    }
}

extension NodeService.DTO.TransactionContainers {
    func anyTransactions(status: TransactionStatus?,
                         scheme: UInt8,
                         aliasScheme: String) -> [AnyTransaction] {
        var anyTransactions = [AnyTransaction]()

        for transaction in transactions {
            anyTransactions.append(transaction.anyTransaction(status: status, scheme: scheme, aliasScheme: aliasScheme))
        }

        return anyTransactions
    }
}

extension AnyTransaction {
    var leaseTransaction: LeaseTransaction? {
        switch self {
        case let .lease(tx):
            return tx

        default:
            return nil
        }
    }

    var transaction: TransactionRealm {
        switch self {
        case let .unrecognised(tx):
            return UnrecognisedTransactionRealm(transaction: tx)

        case let .issue(tx):
            return IssueTransactionRealm(transaction: tx)

        case let .transfer(tx):
            return TransferTransactionRealm(transaction: tx)

        case let .reissue(tx):
            return ReissueTransactionRealm(transaction: tx)

        case let .burn(tx):
            return BurnTransactionRealm(transaction: tx)

        case let .exchange(tx):
            return ExchangeTransactionRealm(transaction: tx)

        case let .lease(tx):
            return LeaseTransactionRealm(transaction: tx)

        case let .leaseCancel(tx):
            return LeaseCancelTransactionRealm(transaction: tx)

        case let .alias(tx):
            return AliasTransactionRealm(transaction: tx)

        case let .massTransfer(tx):
            return MassTransferTransactionRealm(transaction: tx)

        case let .data(tx):
            return DataTransactionRealm(transaction: tx)

        case let .script(tx):
            return ScriptTransactionRealm(transaction: tx)

        case let .assetScript(tx):
            return AssetScriptTransactionRealm(transaction: tx)

        case let .sponsorship(tx):
            return SponsorshipTransactionRealm(transaction: tx)

        case let .invokeScript(tx):
            return InvokeScriptTransactionRealm(transaction: tx)
        case let .updateAssetInfo(tx):
            return UpdateAssetInfoTransactionRealm(transaction: tx)
        }
    }

    func anyTransaction(from: TransactionRealm) -> AnyTransactionRealm {
        let any = AnyTransactionRealm()
        any.type = from.type
        any.id = from.id
        any.sender = from.sender
        any.senderPublicKey = from.senderPublicKey
        any.fee = from.fee
        any.timestamp = from.timestamp
        any.height = from.height
        any.version = from.version
        any.modified = from.modified
        any.status = from.status

        switch self {
        case .unrecognised:
            any.unrecognisedTransaction = from as? UnrecognisedTransactionRealm

        case .issue:
            any.issueTransaction = from as? IssueTransactionRealm

        case .transfer:
            any.transferTransaction = from as? TransferTransactionRealm

        case .reissue:
            any.reissueTransaction = from as? ReissueTransactionRealm

        case .burn:
            any.burnTransaction = from as? BurnTransactionRealm

        case .exchange:
            any.exchangeTransaction = from as? ExchangeTransactionRealm

        case .lease:
            any.leaseTransaction = from as? LeaseTransactionRealm

        case .leaseCancel:
            any.leaseCancelTransaction = from as? LeaseCancelTransactionRealm

        case .alias:
            any.aliasTransaction = from as? AliasTransactionRealm

        case .massTransfer:
            any.massTransferTransaction = from as? MassTransferTransactionRealm

        case .data:
            any.dataTransaction = from as? DataTransactionRealm

        case .script:
            any.scriptTransaction = from as? ScriptTransactionRealm

        case .assetScript:
            any.assetScriptTransaction = from as? AssetScriptTransactionRealm

        case .sponsorship:
            any.sponsorshipTransaction = from as? SponsorshipTransactionRealm

        case .invokeScript:
            any.invokeScriptTransaction = from as? InvokeScriptTransactionRealm
            
        case .updateAssetInfo:
            any.updateAssetInfoTransaction = from as? UpdateAssetInfoTransactionRealm
        }

        return any
    }
}
