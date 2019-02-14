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

        struct Icon {
            let name: String
            let url: String?
        }

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
        let addressRegEx: String
        let iconLogoUrl: String?
        let hasScript: Bool
        let minSponsoredFee: Int64
    }
}

extension DomainLayer.DTO.Asset {

    var iconLogo: DomainLayer.DTO.Asset.Icon {
        return DomainLayer.DTO.Asset.Icon(name: icon, url: iconLogoUrl)
    }

    var icon: String {

        if let gatewayId = gatewayId, gatewayId.count > 0 {
            return gatewayId
        }
        
        return displayName
    }
    
    var isMonero: Bool {
        return gatewayId == "XMR"
    }
    
    var isEthereum: Bool {
        return gatewayId == "ETH"
    }
    
    var isSponsored: Bool {
        return minSponsoredFee > 0
    }
}
