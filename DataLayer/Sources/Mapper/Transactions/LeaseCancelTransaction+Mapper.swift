//
//  LeaseCancelTransaction+Mapper.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 30.08.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Foundation
import WavesSDK

extension LeaseCancelTransaction {
    convenience init(transaction: DomainLayer.DTO.LeaseCancelTransaction) {
        self.init()
        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.senderPublicKey
        fee = transaction.fee
        timestamp = transaction.timestamp
        version = transaction.version
        height = transaction.height
        modified = transaction.modified

        if let proofs = transaction.proofs {
            self.proofs.append(objectsIn: proofs)
        }

        signature = transaction.signature
        chainId.value = transaction.chainId
        leaseId = transaction.leaseId
        if let lease = transaction.lease {
            if let leaseFromBD = realm?.object(ofType: LeaseTransaction.self, forPrimaryKey: leaseId) {
                self.lease = leaseFromBD
            } else {
                self.lease = LeaseTransaction(transaction: lease)
            }
        }
        status = transaction.status.rawValue
    }
}

extension DomainLayer.DTO.LeaseCancelTransaction {
    init(transaction: NodeService.DTO.LeaseCancelTransaction,
         status: DomainLayer.DTO.TransactionStatus,
         aliasScheme: String) {
        
        var leaseTx: DomainLayer.DTO.LeaseTransaction?

        if let lease = transaction.lease {
            leaseTx = DomainLayer.DTO.LeaseTransaction(transaction: lease,
                                                       status: .completed,
                                                       aliasScheme: aliasScheme)
        }

        self.init(type: transaction.type,
                  id: transaction.id,
                  sender: transaction.sender.normalizeAddress(aliasScheme: aliasScheme),
                  senderPublicKey: transaction.senderPublicKey,
                  fee: transaction.fee,
                  timestamp: transaction.timestamp,
                  version: transaction.version,
                  height: transaction.height ?? -1,
                  signature: transaction.signature,
                  proofs: transaction.proofs,
                  chainId: transaction.chainId,
                  leaseId: transaction.leaseId,
                  lease: leaseTx,
                  modified: Date(),
                  status: status)
    }

    init(transaction: LeaseCancelTransaction) {
        var leaseTx: DomainLayer.DTO.LeaseTransaction?

        if let lease = transaction.lease {
            leaseTx = DomainLayer.DTO.LeaseTransaction(transaction: lease)
        }

        self.init(type: transaction.type,
                  id: transaction.id,
                  sender: transaction.sender,
                  senderPublicKey: transaction.senderPublicKey,
                  fee: transaction.fee,
                  timestamp: transaction.timestamp,
                  version: transaction.version,
                  height: transaction.height,
                  signature: transaction.signature,
                  proofs: transaction.proofs.toArray(),
                  chainId: transaction.chainId.value,
                  leaseId: transaction.leaseId,
                  lease: leaseTx,
                  modified: transaction.modified,
                  status: DomainLayer.DTO.TransactionStatus(rawValue: transaction.status) ?? .completed)
    }
}
