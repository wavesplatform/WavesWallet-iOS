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
    func anyTransaction(status: TransactionStatus,
                        scheme: UInt8,
                        aliasScheme: String) -> AnyTransaction {
        switch self {
        case .unrecognised(let transaction):
            return .unrecognised(.init(transaction: transaction, status: status, aliasScheme: aliasScheme))

        case .issue(let transaction):
            return .issue(.init(transaction: transaction, status: status, aliasScheme: aliasScheme))

        case .transfer(let transaction):
            return .transfer(.init(transaction: transaction, status: status, aliasScheme: aliasScheme))

        case .reissue(let transaction):
            return .reissue(.init(transaction: transaction, status: status, aliasScheme: aliasScheme))

        case .burn(let transaction):
            return .burn(.init(transaction: transaction, status: status, aliasScheme: aliasScheme))

        case .exchange(let transaction):
            return .exchange(.init(transaction: transaction, status: status, aliasScheme: aliasScheme))

        case .lease(let transaction):
            return .lease(.init(transaction: transaction, status: status, aliasScheme: aliasScheme))

        case .leaseCancel(let transaction):
            return .leaseCancel(.init(transaction: transaction, status: status, aliasScheme: aliasScheme))

        case .alias(let transaction):
            return .alias(.init(transaction: transaction, status: status, aliasScheme: aliasScheme))

        case .massTransfer(let transaction):
            return .massTransfer(.init(transaction: transaction, status: status, aliasScheme: aliasScheme))

        case .data(let transaction):
            return .data(.init(transaction: transaction, status: status, aliasScheme: aliasScheme))

        case .script(let transaction):
            return .script(.init(transaction: transaction, status: status, aliasScheme: aliasScheme))

        case .assetScript(let transaction):
            return .assetScript(.init(transaction: transaction, status: status, aliasScheme: aliasScheme))

        case .sponsorship(let transaction):
            return .sponsorship(.init(transaction: transaction, status: status, aliasScheme: aliasScheme))

        case .invokeScript(let transaction):
            return .invokeScript(.init(transaction: transaction, status: status, aliasScheme: aliasScheme))
        }
    }
}

extension NodeService.DTO.TransactionContainers {
    func anyTransactions(status: TransactionStatus,
                         scheme: UInt8,
                         aliasScheme: String) -> [AnyTransaction] {
        var anyTransactions = [AnyTransaction]()

        for transaction in self.transactions {
            anyTransactions.append(transaction.anyTransaction(status: status, scheme: scheme, aliasScheme: aliasScheme))
        }

        return anyTransactions
    }
}

extension AnyTransaction {
    var leaseTransaction: LeaseTransaction? {
        switch self {
        case .lease(let tx):
            return tx

        default:
            return nil
        }
    }

    var transaction: TransactionRealm {
        switch self {
        case .unrecognised(let tx):
            return UnrecognisedTransactionRealm(transaction: tx)

        case .issue(let tx):
            return IssueTransactionRealm(transaction: tx)

        case .transfer(let tx):
            return TransferTransactionRealm(transaction: tx)

        case .reissue(let tx):
            return ReissueTransactionRealm(transaction: tx)

        case .burn(let tx):
            return BurnTransactionRealm(transaction: tx)

        case .exchange(let tx):
            return ExchangeTransactionRealm(transaction: tx)

        case .lease(let tx):
            return LeaseTransactionRealm(transaction: tx)

        case .leaseCancel(let tx):
            return LeaseCancelTransactionRealm(transaction: tx)

        case .alias(let tx):
            return AliasTransactionRealm(transaction: tx)

        case .massTransfer(let tx):
            return MassTransferTransactionRealm(transaction: tx)

        case .data(let tx):
            return DataTransactionRealm(transaction: tx)

        case .script(let tx):
            return ScriptTransactionRealm(transaction: tx)

        case .assetScript(let tx):
            return AssetScriptTransactionRealm(transaction: tx)

        case .sponsorship(let tx):
            return SponsorshipTransactionRealm(transaction: tx)

        case .invokeScript(let tx):
            return InvokeScriptTransactionRealm(transaction: tx)
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
        }

        return any
    }
}
