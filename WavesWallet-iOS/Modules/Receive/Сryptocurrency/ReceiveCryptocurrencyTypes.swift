//
//  ReceiveCryptocurrencyTapes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/5/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import WavesSDK
import DomainLayer
import Extensions

enum ReceiveCryptocurrency {
    enum DTO {}
    
    enum Event {
        case generateAddress(asset: DomainLayer.DTO.Asset)
        case addressDidGenerate(ResponseType<DTO.DisplayInfo>)        
    }
    
    struct State: Mutating, Equatable {
        enum Action: Equatable {
            case none
            case addressDidGenerate
            case addressDidFailGenerate(NetworkError)
        }
        
        var isNeedGenerateAddress: Bool
        var action: Action
        var displayInfo: DTO.DisplayInfo?
        var asset: DomainLayer.DTO.Asset?
    }
}

extension ReceiveCryptocurrency.DTO {
    
    struct DisplayInfo: Equatable {
        let addresses: [String]
        let assetName: String
        let assetShort: String
        let minAmount: Money
        let icon: AssetLogo.Icon
    }
}
