//
//  CoinomatDomainDTO.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/14/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension DomainLayer.DTO {
    enum Coinomat {
        
        struct TunnelInfo {
            let address: String
            let attachment: String
        }
        
        struct Rate {
            let fee: Money
            let min: Money
            let max: Money
        }

        struct CardLimit {
            let min: Money
            let max: Money
        }        
    }
}
