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

extension LeaseCancelTransactionRealm {
    convenience init(transaction: LeaseCancelTransaction) {
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
        chainId.value = Int8(transaction.chainId ?? 0)
        leaseId = transaction.leaseId
        if let lease = transaction.lease {
            if let leaseFromBD = realm?.object(ofType: LeaseTransactionRealm.self, forPrimaryKey: leaseId) {
                self.lease = leaseFromBD
            } else {
                self.lease = LeaseTransactionRealm(transaction: lease)
            }
        }
        status = transaction.status.rawValue
    }
}

extension LeaseCancelTransaction {
    init(transaction: NodeService.DTO.LeaseCancelTransaction,
         status: TransactionStatus?,
         aliasScheme: String) {
        
        var leaseTx: LeaseTransaction?

        if let lease = transaction.lease {
            leaseTx = LeaseTransaction(transaction: lease,
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
                  status: status ?? transaction.applicationStatus?.transactionStatus ?? .completed)
    }

    init(transaction: LeaseCancelTransactionRealm) {
        var leaseTx: LeaseTransaction?

        if let lease = transaction.lease {
            leaseTx = LeaseTransaction(transaction: lease)
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
                  chainId: UInt8(transaction.chainId.value ?? 0),
                  leaseId: transaction.leaseId,
                  lease: leaseTx,
                  modified: transaction.modified,
                  status: TransactionStatus(rawValue: transaction.status) ?? .completed)
    }
}
