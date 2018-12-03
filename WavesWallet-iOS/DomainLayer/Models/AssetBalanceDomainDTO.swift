//
//  AssetBalanceDomainDTO.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 05/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension DomainLayer.DTO {

    struct SmartAssetBalance: Mutating {
        struct Settings: Mutating {
            let assetId: String
            var sortLevel: Float
            var isHidden: Bool
            var isFavorite: Bool
        }
        let assetId: String
        //TODO: Rename totalBalance
        var totalBalance: Int64
        var leasedBalance: Int64
        var inOrderBalance: Int64
        var settings: Settings?
        var asset: DomainLayer.DTO.Asset?
        var modified: Date
    }

    struct AssetBalance: Mutating {

        let assetId: String
        var totalBalance: Int64
        var leasedBalance: Int64
        var inOrderBalance: Int64
        var modified: Date
    }
}

extension DomainLayer.DTO.SmartAssetBalance {

    var avaliableBalance: Int64 {
        return totalBalance - leasedBalance - inOrderBalance
    }
}
