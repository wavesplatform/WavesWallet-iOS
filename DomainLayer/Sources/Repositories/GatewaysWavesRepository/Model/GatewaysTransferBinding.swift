//
//  GatewaysTransferBinding.swift
//  DomainLayer
//
//  Created by rprokofev on 28.04.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation

public struct GatewaysTransferBinding {
    public var assetBinding: GatewaysAssetBinding

    public var addresses: [String]

    public var recipient: String

    public init(assetBinding: GatewaysAssetBinding, addresses: [String], recipient: String) {
        self.assetBinding = assetBinding
        self.addresses = addresses
        self.recipient = recipient
    }
}
