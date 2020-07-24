//
//  DexTraderContainerTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/15/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import DomainLayer

public enum DexTraderContainer {
    public enum DTO {}
}

public extension DexTraderContainer.DTO {
    
    struct Pair {
        public let amountAsset: Asset
        public let priceAsset: Asset
        public let isGeneral: Bool

        public init(amountAsset: Asset, priceAsset: Asset, isGeneral: Bool) {
            self.amountAsset = amountAsset
            self.priceAsset = priceAsset
            self.isGeneral = isGeneral
        }
    }
}
