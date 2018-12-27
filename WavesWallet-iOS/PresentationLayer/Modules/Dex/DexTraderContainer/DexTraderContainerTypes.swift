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
        let amountAsset: DomainLayer.DTO.Dex.Asset
        let priceAsset: DomainLayer.DTO.Dex.Asset
        let isGeneral: Bool
    }
}
