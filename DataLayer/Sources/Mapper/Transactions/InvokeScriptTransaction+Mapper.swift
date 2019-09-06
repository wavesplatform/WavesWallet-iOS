//
//  InvokeScriptTransaction+Mapper.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/9/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDK
import DomainLayer

extension InvokeScriptTransaction {
    
    convenience init(transaction: DomainLayer.DTO.InvokeScriptTransaction) {
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
            payment = InvokeScriptTransactionPayment()
            payment?.amount = txPayment.amount
            payment?.assetId = txPayment.assetId
        }

    }
}
extension DomainLayer.DTO.InvokeScriptTransaction {
    
    init(transaction: NodeService.DTO.InvokeScriptTransaction, status: DomainLayer.DTO.TransactionStatus, environment: WalletEnvironment) {
        
        
        var call: DomainLayer.DTO.InvokeScriptTransaction.Call? = nil
        
        if let localCall = transaction.call {
            let args = localCall.args.map { (arg) -> DomainLayer.DTO.InvokeScriptTransaction.Call.Args in
                
                let value = { () -> DomainLayer.DTO.InvokeScriptTransaction.Call.Args.Value in
                 
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
            
            call = DomainLayer.DTO.InvokeScriptTransaction.Call.init(function: localCall.function, args: args)
        }
        
        self.init(type: transaction.type,
                  id: transaction.id,
                  sender: transaction.sender.normalizeAddress(environment: environment),
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
    
    init(transaction: InvokeScriptTransaction) {
        
        //TODO: chainId: String
        //TODO: Call to bd
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
                  status: DomainLayer.DTO.TransactionStatus(rawValue: transaction.status) ?? .completed,
                  chainId: "",
                  call: nil)
    }
}
