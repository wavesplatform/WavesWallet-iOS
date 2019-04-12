//
//  InvokeScriptTransaction+Mapper.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/9/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

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
    
    init(transaction: Node.DTO.InvokeScriptTransaction, status: DomainLayer.DTO.TransactionStatus, environment: Environment) {
        type = transaction.type
        id = transaction.id
        sender = transaction.sender.normalizeAddress(environment: environment)
        senderPublicKey = transaction.senderPublicKey
        fee = transaction.fee
        feeAssetId = transaction.feeAssetId
        timestamp = transaction.timestamp
        proofs = transaction.proofs
        version = transaction.version
        dappAddress = transaction.dappAddress
        height = transaction.height
        payment = transaction.payment.first.map { .init(amount: $0.amount, assetId: $0.assetId) }
        
        modified = Date()
        self.status = status
    }
    
    init(transaction: InvokeScriptTransaction) {
        
        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.senderPublicKey
        fee = transaction.fee
        feeAssetId = transaction.feeAssetId
        timestamp = transaction.timestamp
        version = transaction.version
        dappAddress = transaction.dappAddress
        height = transaction.height
        proofs = transaction.proofs.toArray()
        payment = transaction.payment.map { .init(amount: $0.amount, assetId: $0.assetId) }
        
        modified = transaction.modified
        status = DomainLayer.DTO.TransactionStatus(rawValue: transaction.status) ?? .completed
    }

}
