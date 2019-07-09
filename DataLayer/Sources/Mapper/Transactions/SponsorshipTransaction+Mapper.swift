//
//  SponsorshipTransaction+Mapper.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 05/02/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDKExtensions
import WavesSDK
import DomainLayer

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

        if let proofs = transaction.proofs {
            self.proofs.append(objectsIn: proofs)
        }
        modified = transaction.modified
        status = transaction.status.rawValue
    }
}

extension DomainLayer.DTO.SponsorshipTransaction {

    init(transaction: NodeService.DTO.SponsorshipTransaction, status: DomainLayer.DTO.TransactionStatus, environment: WalletEnvironment) {

        self.init(type: transaction.type,
                  id: transaction.id,
                  sender: transaction.sender.normalizeAddress(environment: environment),
                  senderPublicKey: transaction.senderPublicKey,
                  fee: transaction.fee,
                  timestamp: transaction.timestamp,
                  version: transaction.version,
                  height: transaction.height,
                  signature: transaction.signature,
                  proofs: transaction.proofs,
                  assetId: transaction.assetId,
                  minSponsoredAssetFee: transaction.minSponsoredAssetFee,
                  modified: Date(),
                  status: status)
    }

    init(transaction: SponsorshipTransaction) {
        
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
                  assetId: transaction.assetId,
                  minSponsoredAssetFee: transaction.minSponsoredAssetFee.value,
                  modified: transaction.modified,
                  status: DomainLayer.DTO.TransactionStatus(rawValue: transaction.status) ?? .completed)
    }
}



