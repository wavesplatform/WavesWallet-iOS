//
//  AssetDetailNode.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 21/01/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

extension Node.DTO {

    struct AssetDetail: Decodable {
        let assetId: String
        let issueHeight: Int64
        let issueTimestamp: Int64
        let issuer: String
        let name: String
        let description: String
        let decimals: Int64
        let reissuable: Bool
        let quantity: Int64
        let scripted: String?
        let minSponsoredAssetFee: Int64?
    }
}
