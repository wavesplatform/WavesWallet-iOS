//
//  ReissueTransaction+Mapper.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 30.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension ReissueTransaction {

    convenience init(transaction: DomainLayer.DTO.ReissueTransaction) {
        self.init()
        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.sender
        fee = transaction.fee
        timestamp = transaction.timestamp
        version = transaction.version
        height = transaction.height
        modified = transaction.modified

        signature = transaction.signature
        assetId = transaction.assetId
        chainId = transaction.chainId
        quantity = transaction.quantity
        reissuable = transaction.reissuable
    }
}

extension DomainLayer.DTO.ReissueTransaction {

    init(transaction: Node.DTO.ReissueTransaction) {

        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.sender
        fee = transaction.fee
        timestamp = transaction.timestamp
        version = transaction.version
        height = transaction.height
        modified = Date()

        signature = transaction.signature
        assetId = transaction.assetId
        chainId = transaction.chainId
        quantity = transaction.quantity
        reissuable = transaction.reissuable
    }

    init(transaction: ReissueTransaction) {
        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.sender
        fee = transaction.fee
        timestamp = transaction.timestamp
        version = transaction.version
        height = transaction.height
        modified = transaction.modified

        signature = transaction.signature
        assetId = transaction.assetId
        chainId = transaction.chainId
        quantity = transaction.quantity
        reissuable = transaction.reissuable
    }
}
