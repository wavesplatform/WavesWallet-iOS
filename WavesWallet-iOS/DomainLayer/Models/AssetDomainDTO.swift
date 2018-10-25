//
//  File.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 04/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

extension DomainLayer.DTO {
    struct Asset: Mutating {
        let id: String
        let gatewayId: String?
        let wavesId: String?
        let displayName: String
        let precision: Int
        let description: String
        let height: Int64
        let timestamp: Date
        let sender: String
        let quantity: Int64
        let ticker: String?
        let isReusable: Bool
        var isSpam: Bool
        let isFiat: Bool
        let isGeneral: Bool
        let isMyWavesToken: Bool
        let isWavesToken: Bool
        let isGateway: Bool
        let isWaves: Bool
        let modified: Date
        let regularExpression: String
    }
}


extension DomainLayer.DTO.Asset {
    var icon: String {
        return ticker ?? displayName
    }
    
    var isMonero: Bool {
        return gatewayId == "XMR"
    }
}
