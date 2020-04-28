//
//  GetWavesAssetBindingsRequest.swift
//  DomainLayer
//
//  Created by rprokofev on 28.04.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation

struct AssetBindingsRequest {
    enum Direction {
        case withdraw
        case deposit
    }

    enum AssetType {
        case fiat
        case crypto
    }

    let assetType: AssetType
    let direction: Direction
    let includesExternalAssetTicker: String?
    let includesWavesAsset: String?

    public init(assetType: AssetType, direction: Direction, includesExternalAssetTicker: String?, includesWavesAsset: String?) {
        self.assetType = assetType
        self.direction = direction
        self.includesExternalAssetTicker = includesExternalAssetTicker
        self.includesWavesAsset = includesWavesAsset
    }
}
