//
//  ConfirmRequestDTORequest+Mapper.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 30.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDK

extension ConfirmRequest.DTO.ComplitingRequest {
    
    var nodeServiceQueryTransaction: NodeService.Query.Transaction? {
        
        switch self.transaction {
            
        case .data(let tx):
        
            let data = tx.data.map { (value) -> NodeService.Query.Transaction.Data.Value in
                
                let kind: NodeService.Query.Transaction.Data.Value.Kind = {
                    switch value.value {
                    case .binary(let value):
                        return .binary(value)
                        
                    case .boolean(let value):
                        return .boolean(value)
                        
                    case .integer(let value):
                        return .integer(value)
                        
                    case .string(let value):
                        return .string(value)
                    }
                }()
                
                return NodeService.Query.Transaction.Data.Value(key: value.key,
                                                                value: kind)
            }

            let query = NodeService
                .Query
                .Transaction
                .Data.init(fee: tx.fee.amount,
                           timestamp: timestamp.millisecondsSince1970,
                           senderPublicKey: signedWallet.publicKey.getPublicKeyStr(),
                           data: data,
                           chainId: tx.chainId)

            return .data(query)
            
        case .transfer(let tx):
            
            let query = NodeService
                .Query
                .Transaction
                .Transfer.init(recipient: tx.recipient,
                               assetId: tx.asset.id,
                               amount: tx.amount.amount,
                               fee: tx.fee.amount,
                               attachment: tx.attachment,
                               feeAssetId: tx.feeAsset.id,
                               timestamp: timestamp.millisecondsSince1970,
                               senderPublicKey: signedWallet.publicKey.getPublicKeyStr(),
                               chainId: tx.chainId)
            
            return .transfer(query)
            
        case .invokeScript(let tx):

            var callQuery: NodeService
            .Query
            .Transaction
            .InvokeScript.Call? = nil
           
            if let call = tx.call {
                
                let args = call.args.map { (arg) -> NodeService.Query.Transaction.InvokeScript.Arg in
                    
                    let value: NodeService.Query.Transaction.InvokeScript.Arg.Value = {
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
                    
                    return NodeService.Query.Transaction.InvokeScript.Arg(value: value)
                }
                
                callQuery = .init(function: call.function, args: args)
            }
           
            let paymets = tx.payment.map {
                return NodeService
                    .Query
                    .Transaction
                    .InvokeScript.Payment.init(amount: $0.amount.amount,
                                               assetId: $0.asset.id)
            }
            
            let query = NodeService
                .Query
                .Transaction
                .InvokeScript.init(chainId: tx.chainId,
                                   fee: tx.fee.amount,
                                   timestamp: timestamp.millisecondsSince1970,
                                   senderPublicKey: signedWallet.publicKey.getPublicKeyStr(),
                                   feeAssetId: tx.feeAsset.id,
                                   dApp: tx.dApp,
                                   call: callQuery,
                                   payment: paymets)
            
            return .invokeScript(query)
        }
    }
}
