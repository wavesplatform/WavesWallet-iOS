//
//  SponsorshipTransaction+Mapper.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 05/02/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDKExtension

extension SponsorshipTransaction {

    convenience init(transaction: DomainLayer.DTO.SponsorshipTransaction) {
        self.init()
        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.sender
        fee = transaction.fee
        timestamp = transaction.timestamp
        height = transaction.height ?? -1
        signature = transaction.signature
        version = transaction.version
        minSponsoredAssetFee.value = transaction.minSponsoredAssetFee
        assetId = transaction.assetId

        modified = transaction.modified
        status = transaction.status.rawValue
    }
}

extension DomainLayer.DTO.SponsorshipTransaction {

    init(transaction: Node.DTO.SponsorshipTransaction, status: DomainLayer.DTO.TransactionStatus, environment: Environment) {

        type = transaction.type
        id = transaction.id
        sender = transaction.sender.normalizeAddress(environment: environment)
        senderPublicKey = transaction.senderPublicKey
        fee = transaction.fee
        timestamp = transaction.timestamp
        height = transaction.height ?? -1
        signature = transaction.signature
        proofs = transaction.proofs
        assetId = transaction.assetId
        version = transaction.version
        minSponsoredAssetFee = transaction.minSponsoredAssetFee
        self.assetId = transaction.assetId
        modified = Date()
        self.status = status
    }

    init(transaction: SponsorshipTransaction) {
        type = transaction.type
        id = transaction.id
        sender = transaction.sender
        senderPublicKey = transaction.sender
        fee = transaction.fee
        timestamp = transaction.timestamp
        height = transaction.height
        signature = transaction.signature
        proofs = transaction.proofs.toArray()
        assetId = transaction.assetId
        version = transaction.version
        minSponsoredAssetFee = transaction.minSponsoredAssetFee.value
        self.assetId = transaction.assetId

        modified = transaction.modified
        status = DomainLayer.DTO.TransactionStatus(rawValue: transaction.status) ?? .completed
    }
}



