//
//  GatewayDomainDTO.swift
//  InternalDomainLayer
//
//  Created by Pavel Gubin on 22.06.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import Extensions

public extension DomainLayer.DTO {
    
    enum GatewayType: String {
        case coinomat
        case gateway
    }
    
    enum Gateway {
        public struct StartWithdrawProcess {
            public let recipientAddress: String
            public let minAmount: Money
            public let maxAmount: Money
            public let fee: Money
            public let processId: String
        
            public init(recipientAddress: String, minAmount: Money, maxAmount: Money, fee: Money, processId: String) {
                self.recipientAddress = recipientAddress
                self.minAmount = minAmount
                self.maxAmount = maxAmount
                self.fee = fee
                self.processId = processId
            }
        }
        
        public struct StartDepositProcess {
            public let address: String
            public let minAmount: Money
            public let maxAmount: Money
            
            public init(address: String, minAmount: Money, maxAmount: Money) {
                self.address = address
                self.minAmount = minAmount
                self.maxAmount = maxAmount
            }
        }
    }
}
