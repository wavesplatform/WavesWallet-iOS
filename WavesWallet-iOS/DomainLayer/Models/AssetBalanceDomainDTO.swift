//
//  AssetBalanceDomainDTO.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 05/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension DomainLayer.DTO {

    struct AssetBalance: Mutating {
        struct Settings: Mutating {
            let assetId: String
            var sortLevel: Float
            var isHidden: Bool
            var isFavorite: Bool
        }
        let assetId: String
        var balance: Int64
        var leasedBalance: Int64
        var reserveBalance: Int64
        var settings: Settings?
        var asset: DomainLayer.DTO.Asset?
        var modified: Date
    } 
}
