//
//  ReceiveCryptocurrencyTapes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/5/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum ReceiveCryptocurrency {
    enum DTO {}
    
    enum Event {
        case generateAddress(asset: DomainLayer.DTO.Asset)
        case addressDidGenerate(Responce<DTO.DisplayInfo>)
    }
    
    struct State: Mutating {
        enum Action {
            case none
            case addressDidGenerate(DTO.DisplayInfo)
            case addressDidFailGenerate(Error)
        }
        
        var isNeedGenerateAddress: Bool
        var action: Action
        var displayInfo: DTO.DisplayInfo?
        var asset: DomainLayer.DTO.Asset?
    }
}

extension ReceiveCryptocurrency.DTO {
    
    struct DisplayInfo {
        let address: String
        let assetName: String
        let assetTicker: String
        let fee: Double
    }
}
