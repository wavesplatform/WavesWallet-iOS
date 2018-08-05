//
//  File.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 04/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension DomainLayer.DTO {
    struct Asset {
        let id: String
        let name: String
        let precision: Int
        let description: String
        let height: Int64
        let timestamp: String
        let sender: String
        let quantity: Int64
        let ticker: String?
        let isReissuable: Bool
        let isSpam: Bool
        let isFiat: Bool
        let isGeneral: Bool
        let isMyAsset: Bool
        let isGateway: Bool
        let isWaves: Bool
        let modified: Date
    }
}
