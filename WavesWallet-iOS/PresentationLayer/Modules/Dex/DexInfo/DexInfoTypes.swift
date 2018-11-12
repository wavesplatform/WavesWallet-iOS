//
//  DexInfoTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/11/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation


enum DexInfoPair {
    enum DTO {}
}


extension DexInfoPair.DTO {
    
    struct Pair: Mutating {
        let amountAsset: Dex.DTO.Asset
        let priceAsset: Dex.DTO.Asset
        let isGeneral: Bool
    }
}

