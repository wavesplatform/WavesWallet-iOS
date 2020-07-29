//
//  InvokeScriptTransaction+Mapper.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/9/19.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import DomainLayer
import Foundation
import WavesSDK

extension InvokeScriptTransactionRealm {
    convenience init(transaction: InvokeScriptTransaction) {
        self.init()

        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.sender
        fee = transaction.fee
        timestamp = transaction.timestamp
        height = transaction.height
        version = transaction.version

        if let proofs = transaction.proofs {
            self.proofs.append(objectsIn: proofs)
        }
        feeAssetId = transaction.feeAssetId
        dappAddress = transaction.dappAddress

        modified = transaction.modified
        status = transaction.status.rawValue

        let list = transaction.payments?.map { payment -> InvokeScriptTransactionPaymentRealm in

            let realmPayment = InvokeScriptTransactionPaymentRealm()
            realmPayment.amount = payment.amount
            realmPayment.assetId = payment.assetId
            return realmPayment
        } ?? []
        self.payments.append(objectsIn: list)
    }
}

extension InvokeScriptTransaction {
    init(transaction: NodeService.DTO.InvokeScriptTransaction,
         status: TransactionStatus?,
         aliasScheme: String) {
        var call: InvokeScriptTransaction.Call?

        if let localCall = transaction.call {
            let args = localCall.args.map { (arg) -> InvokeScriptTransaction.Call.Args in

                let value = { () -> InvokeScriptTransaction.Call.Args.Value in

                    switch arg.value {
                    case let .binary(value):
                        return .binary(value)

                    case let .bool(value):
                        return .bool(value)

                    case let .integer(value):
                        return .integer(value)

                    case let .string(value):
                        return .string(value)
                    }
                }()

                return .init(type: arg.type, value: value)
            }

            call = InvokeScriptTransaction.Call(function: localCall.function, args: args)
        }

        self.init(type: transaction.type,
                  id: transaction.id,
                  sender: transaction.sender.normalizeAddress(aliasScheme: aliasScheme),
                  senderPublicKey: transaction.senderPublicKey,
                  fee: transaction.fee,
                  feeAssetId: transaction.feeAssetId,
                  timestamp: transaction.timestamp,
                  proofs: transaction.proofs,
                  version: transaction.version,
                  dappAddress: transaction.dApp,
                  payments: transaction.payment.map { .init(amount: $0.amount, assetId: $0.assetId) },
                  height: transaction.height ?? 0,
                  modified: Date(),
                  status: status ?? transaction.applicationStatus?.transactionStatus ?? .completed,
                  chainId: transaction.chainId,
                  call: call)
    }

    init(transaction: InvokeScriptTransactionRealm) {

        let payments = transaction.payments.toArray().map { realmPayment -> InvokeScriptTransaction.Payment in
            InvokeScriptTransaction.Payment(amount: realmPayment.amount, assetId: realmPayment.assetId)
        }
        

        self.init(type: transaction.type,
                  id: transaction.id,
                  sender: transaction.sender,
                  senderPublicKey: transaction.senderPublicKey,
                  fee: transaction.fee,
                  feeAssetId: transaction.feeAssetId,
                  timestamp: transaction.timestamp,
                  proofs: transaction.proofs.toArray(),
                  version: transaction.version,
                  dappAddress: transaction.dappAddress,
                  payments: payments,
                  height: transaction.height,
                  modified: transaction.modified,
                  status: TransactionStatus(rawValue: transaction.status) ?? .completed,
                  chainId: 0,
                  call: nil)
    }
}
