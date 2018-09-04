//
//  TransactionTransferNode.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 07/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension Node.DTO {
    struct TransferTransaction: Decodable {
        let type: Int
        let id: String
        let sender: String
        let senderPublicKey: String
        let fee: Int64
        let timestamp: Int64
        let version: Int
        let height: Int64

        let signature: String
        let recipient: String
        let assetId: String?
        let feeAssetId: String?
        let feeAsset: String?
        let amount: Int64
        let attachment: String?
    }
}
