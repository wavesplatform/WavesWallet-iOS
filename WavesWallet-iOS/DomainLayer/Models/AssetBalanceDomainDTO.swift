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
        let assetId: String
        var totalBalance: Int64
        var leasedBalance: Int64
        var inOrderBalance: Int64
        var settings: DomainLayer.DTO.AssetBalanceSettings
        var asset: DomainLayer.DTO.Asset
        var modified: Date
        let sponsorBalance: Int64
    }

    struct AssetBalance: Mutating {

        let assetId: String
        var totalBalance: Int64
        var leasedBalance: Int64
        var inOrderBalance: Int64
        var modified: Date
        let sponsorBalance: Int64
    }

    struct AssetBalanceSettings: Mutating {
        let assetId: String
        var sortLevel: Float
        var isHidden: Bool
        var isFavorite: Bool
    }
}

extension DomainLayer.DTO.SmartAssetBalance {

    var availableBalance: Int64 {
        return max(totalBalance - leasedBalance - inOrderBalance, 0)
    }
}
