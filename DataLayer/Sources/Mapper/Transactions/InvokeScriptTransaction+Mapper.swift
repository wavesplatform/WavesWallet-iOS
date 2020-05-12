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
        
        if let txPayment = transaction.payment {
            payment = InvokeScriptTransactionPaymentRealm()
            payment?.amount = txPayment.amount
            payment?.assetId = txPayment.assetId
        }
    }
}

extension InvokeScriptTransaction {
    init(transaction: NodeService.DTO.InvokeScriptTransaction,
         status: TransactionStatus,
         aliasScheme: String) {
        var call: InvokeScriptTransaction.Call?
        
        if let localCall = transaction.call {
            let args = localCall.args.map { (arg) -> InvokeScriptTransaction.Call.Args in
                
                let value = { () -> InvokeScriptTransaction.Call.Args.Value in
                    
                    switch arg.value {
                    case .binary(let value):
                        return .binary(value)
                        
                    case .bool(let value):
                        return .bool(value)
                        
                    case .integer(let value):
                        return .integer(value)
                        
                    case .string(let value):
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
                  payment: transaction.payment.first.map { .init(amount: $0.amount, assetId: $0.assetId) },
                  height: transaction.height ?? 0,
                  modified: Date(),
                  status: status,
                  chainId: transaction.chainId,
                  call: call)
    }
    
    init(transaction: InvokeScriptTransactionRealm) {
        // TODO: chainId: String
        // TODO: Call to bd
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
                  payment: transaction.payment.map { .init(amount: $0.amount, assetId: $0.assetId) },
                  height: transaction.height,
                  modified: transaction.modified,
                  status: TransactionStatus(rawValue: transaction.status) ?? .completed,
                  chainId: "",
                  call: nil)
    }
}
