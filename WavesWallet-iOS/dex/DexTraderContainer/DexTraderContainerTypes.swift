//
//  DexTraderContainerTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/15/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum DexTraderContainer {
    enum DTO {}
}

extension DexTraderContainer.DTO {
    
    struct Asset {
        let id: String
        let name: String
        let decimals: Int
    }
    
    struct Pair {
        let amountAsset: Asset
        let priceAsset: Asset
    }
}
