//
//  GatewaysAsset.swift
//  DomainLayer
//
//  Created by rprokofev on 28.04.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation

public struct GatewaysAsset {
    public enum TypeAsset {
        case crypto
        case fiat
    }

    public var asset: String

    public var decimals: Int32

    public var ticker: String

    public var type: TypeAsset

    public init(asset: String, decimals: Int32, ticker: String, type: TypeAsset) {
        self.asset = asset
        self.decimals = decimals
        self.ticker = ticker
        self.type = type
    }
}
