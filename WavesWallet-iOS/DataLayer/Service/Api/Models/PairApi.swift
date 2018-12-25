//
//  PairApi.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/26/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension API.DTO {
    
    struct Pair: Decodable {
        let amountAsset: String
        let priceAsset: String
    }
}
