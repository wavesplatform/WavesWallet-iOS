//
//  AssetDetailNode.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 21/01/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

extension DomainLayer.DTO {

    struct AssetDetail {
        let assetId: String
        let issueHeight: Int64
        let issueTimestamp: Int64
        let issuer: String
        let name: String
        let description: String
        let decimals: Int64
        let reissuable: Bool
        let quantity: Int64
        let scripted: String
        let minSponsoredAssetFee: Int64?
    }
}
//{
//    "assetId": "8LQW8f7P5d5PZM7GtZEBgaqRPGSzS3DfPuiXrURJ4AJS",
//    "issueHeight": 257457,
//    "issueTimestamp": 1480690876160,
//    "issuer": "3PC4roN512iugc6xGVTTM2XkoWKEdSiiscd",
//    "name": "WBTC",
//    "description": "Bitcoin Token",
//    "decimals": 8,
//    "reissuable": false,
//    "quantity": 2099999999662710,
//    "scripted": false,
//    "minSponsoredAssetFee": null
//}
