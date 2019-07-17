//
//  AssetBalanceDomainDTO.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 05/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDKExtensions
import Extensions

public extension DomainLayer.DTO {

    struct SmartAssetBalance: Mutating {
        public let assetId: String
        public var totalBalance: Int64
        public var leasedBalance: Int64
        public var inOrderBalance: Int64
        public var settings: DomainLayer.DTO.AssetBalanceSettings
        public var asset: DomainLayer.DTO.Asset
        public var modified: Date
        public let sponsorBalance: Int64

        public init(assetId: String, totalBalance: Int64, leasedBalance: Int64, inOrderBalance: Int64, settings: DomainLayer.DTO.AssetBalanceSettings, asset: DomainLayer.DTO.Asset, modified: Date, sponsorBalance: Int64) {
            self.assetId = assetId
            self.totalBalance = totalBalance
            self.leasedBalance = leasedBalance
            self.inOrderBalance = inOrderBalance
            self.settings = settings
            self.asset = asset
            self.modified = modified
            self.sponsorBalance = sponsorBalance
        }
    }

    struct AssetBalance: Mutating {

        public let assetId: String
        public var totalBalance: Int64
        public var leasedBalance: Int64
        public var inOrderBalance: Int64
        public var modified: Date
        public let sponsorBalance: Int64
        public let minSponsoredAssetFee: Int64

        public init(assetId: String, totalBalance: Int64, leasedBalance: Int64, inOrderBalance: Int64, modified: Date, sponsorBalance: Int64, minSponsoredAssetFee: Int64) {
            self.assetId = assetId
            self.totalBalance = totalBalance
            self.leasedBalance = leasedBalance
            self.inOrderBalance = inOrderBalance
            self.modified = modified
            self.sponsorBalance = sponsorBalance
            self.minSponsoredAssetFee = minSponsoredAssetFee
        }
    }

    struct AssetBalanceSettings: Mutating {
        public let assetId: String
        public var sortLevel: Float
        public var isHidden: Bool
        public var isFavorite: Bool

        public init(assetId: String, sortLevel: Float, isHidden: Bool, isFavorite: Bool) {
            self.assetId = assetId
            self.sortLevel = sortLevel
            self.isHidden = isHidden
            self.isFavorite = isFavorite
        }
    }
}

public extension DomainLayer.DTO.SmartAssetBalance {

    var availableBalance: Int64 {
        return max(totalBalance - leasedBalance - inOrderBalance, 0)
    }
}
