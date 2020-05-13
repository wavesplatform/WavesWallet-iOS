//
//  SponsorshipTransaction+Mapper.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 05/02/2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import DomainLayer
import Foundation
import WavesSDK
import WavesSDKExtensions

extension SponsorshipTransactionRealm {
    convenience init(transaction: SponsorshipTransaction) {
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

extension SponsorshipTransaction {
    init(transaction: NodeService.DTO.SponsorshipTransaction,
         status: TransactionStatus,
         aliasScheme: String) {
        self.init(type: transaction.type,
                  id: transaction.id,
                  sender: transaction.sender.normalizeAddress(aliasScheme: aliasScheme),
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

    init(transaction: SponsorshipTransactionRealm) {
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
                  status: TransactionStatus(rawValue: transaction.status) ?? .completed)
    }
}
