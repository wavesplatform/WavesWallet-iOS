//
//  GetWavesAssetBindingsRequest.swift
//  DomainLayer
//
//  Created by rprokofev on 28.04.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation

public struct AssetBindingsRequest {
    public enum Direction {
        case withdraw
        case deposit
    }

    public enum AssetType {
        case fiat
        case crypto
    }

    public let assetType: AssetType
    public let direction: Direction
    public let includesExternalAssetTicker: String?
    public let includesWavesAsset: String?

    public init(assetType: AssetType, direction: Direction, includesExternalAssetTicker: String?, includesWavesAsset: String?) {
        self.assetType = assetType
        self.direction = direction
        self.includesExternalAssetTicker = includesExternalAssetTicker
        self.includesWavesAsset = includesWavesAsset
    }
}
