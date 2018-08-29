//
//  TransactionTransferNode.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 07/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension Node.DTO {
    struct TransactionTransfer: Decodable {
        let type: Int
        let id: String
        let sender: String
        let senderPublicKey: String
        let fee: Int64
        let timestamp: Int64
        let signature: String
        let version: Int
        let recipient: String
        let assetID: String?
        let feeAssetID: String?
        let feeAsset: Int64?
        let amount: Int64
        let attachment: String
        let height: Int64
    }
}
