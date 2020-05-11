//
//  GatewaysAssetBinding.swift
//  DomainLayer
//
//  Created by rprokofev on 28.04.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation

public struct GatewaysAssetBinding {
    public var senderAsset: GatewaysAsset

    public var recipientAsset: GatewaysAsset

    public var hasRecipientAsset: Bool

    public var senderAmountMin: Decimal

    public var senderAmountMax: Decimal

    public var taxFlat: Decimal

    public var taxRate: Double

    public var active: Bool

    public init(senderAsset: GatewaysAsset,
                recipientAsset: GatewaysAsset,
                hasRecipientAsset: Bool,
                senderAmountMin: Decimal,
                senderAmountMax: Decimal,
                taxFlat: Decimal,
                taxRate: Double,
                active: Bool) {
        self.senderAsset = senderAsset
        self.recipientAsset = recipientAsset
        self.hasRecipientAsset = hasRecipientAsset
        self.senderAmountMin = senderAmountMin
        self.senderAmountMax = senderAmountMax
        self.taxFlat = taxFlat
        self.taxRate = taxRate
        self.active = active
    }
}
