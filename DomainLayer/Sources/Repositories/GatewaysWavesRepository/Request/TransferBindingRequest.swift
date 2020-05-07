//
//  GatewaysGetDepositTransferBindingRequest.swift
//  DomainLayer
//
//  Created by rprokofev on 28.04.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation

public struct TransferBindingRequest {
    public var asset: String

    public var recipientAddress: String

    public init(asset: String, recipientAddress: String) {
        self.asset = asset
        self.recipientAddress = recipientAddress
    }
}
