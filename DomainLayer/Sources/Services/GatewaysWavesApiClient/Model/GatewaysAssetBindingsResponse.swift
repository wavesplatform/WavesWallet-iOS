//
//  GatewaysAssetBindingsResponse.swift
//  DomainLayer
//
//  Created by rprokofev on 28.04.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation

public struct GatewaysAssetBindingsResponse {
    public var assetBindings: [GatewaysAssetBinding]

    public init(assetBindings: [GatewaysAssetBinding]) {
        self.assetBindings = assetBindings
    }
}
