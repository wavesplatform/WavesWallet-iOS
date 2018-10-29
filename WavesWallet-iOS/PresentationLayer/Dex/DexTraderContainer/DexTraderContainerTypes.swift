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
    
    struct Pair {
        let amountAsset: Dex.DTO.Asset
        let priceAsset: Dex.DTO.Asset
        let isHidden: Bool
    }
}
