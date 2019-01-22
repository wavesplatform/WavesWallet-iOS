//
//  AssetScriptTransactionNode.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 22/01/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

extension Node.DTO {

    struct AssetScriptTransaction: Decodable {

        let type: Int
        let id: String
        let sender: String
        let senderPublicKey: String
        let fee: Int64
        let timestamp: Int64
        let height: Int64?
        let signature: String?
        let proofs: [String]?
        let chainId: Int?
        let assetId: String
        let version: Int
        let script: String?
    }
}
