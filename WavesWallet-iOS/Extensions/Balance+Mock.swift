//
//  Balance+Mock.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 18.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer
import Extensions

extension DomainLayer.DTO.Balance {
    
    static var randomBalance: DomainLayer.DTO.Balance {
        return .init(currency: .init(title: "USDB",
                                     ticker: "USDB"),
                     money: Money(Int64(arc4random() % 1000000), 2))
    }
}
