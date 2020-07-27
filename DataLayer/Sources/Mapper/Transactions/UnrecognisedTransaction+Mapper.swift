//
//  UnrecognisedTransaction+Mapper.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 31.08.2018.1
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Foundation
import WavesSDK

extension UnrecognisedTransactionRealm {
    convenience init(transaction: UnrecognisedTransaction) {
        self.init()
        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.sender
        fee = transaction.fee
        timestamp = transaction.timestamp
        version = 1
        height = transaction.height
        modified = transaction.modified
        status = transaction.status.rawValue
    }
}

extension UnrecognisedTransaction {
    init(transaction: NodeService.DTO.UnrecognisedTransaction,
         status: TransactionStatus?,
         aliasScheme: String) {
        self.init(type: transaction.type,
                  id: transaction.id,
                  sender: transaction.sender.normalizeAddress(aliasScheme: aliasScheme),
                  senderPublicKey: transaction.senderPublicKey,
                  fee: transaction.fee,
                  timestamp: transaction.timestamp,
                  height: transaction.height,
                  modified: Date(),
                  status: status ?? transaction.applicationStatus?.transactionStatus ?? .completed)
    }

    init(transaction: UnrecognisedTransactionRealm) {
        self.init(type: transaction.type,
                  id: transaction.id,
                  sender: transaction.sender,
                  senderPublicKey: transaction.senderPublicKey,
                  fee: transaction.fee,
                  timestamp: transaction.timestamp,
                  height: transaction.height,
                  modified: transaction.modified,
                  status: TransactionStatus(rawValue: transaction.status) ?? .completed)
    }
}
