//
//  CoinomatDomainDTO.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/14/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Extensions

public extension DomainLayer.DTO {
    enum Coinomat {
        
        public struct TunnelInfo {
            public let address: String
            public let attachment: String
            public let min: Money

            public init(address: String, attachment: String, min: Money) {
                self.address = address
                self.attachment = attachment
                self.min = min
            }
        }
        
        public struct Rate {
            public let fee: Money
            public let min: Money
            public let max: Money

            public init(fee: Money, min: Money, max: Money) {
                self.fee = fee
                self.min = min
                self.max = max
            }
        }

        public struct CardLimit {
            public let min: Money
            public let max: Money

            public init(min: Money, max: Money) {
                self.min = min
                self.max = max
            }
        }        
    }
}
