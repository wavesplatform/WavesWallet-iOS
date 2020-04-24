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
        struct Address: Equatable {
            let name: String
            let address: String
        }
        
        let addresses: [Address]
        let asset: DomainLayer.DTO.Asset
        let minAmount: Money
        let maxAmount: Money?
        
        /// необходимо чтобы правильно, в зависимости от ассета, выставлять тексты на экране
        let generalAssets: [WalletEnvironment.AssetInfo]
    }
}
