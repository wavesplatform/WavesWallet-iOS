//
//  SendTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/17/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum Send {
    enum DTO {}
    enum ViewModel {}

    enum Event {
        case didGetInfo(Responce<DTO.GatewayInfo>)
        case didChangeRecipient(String)
    }
    
    struct State: Mutating {
        enum Action {
            case none
            case didGetInfo
            case didFailGetInfo(Error)
        }
        
        var isNeedLoadInfo: Bool
        var action: Action
        var recipient: String = ""
    }
}

extension Send.DTO {
    
    struct Order {
        let asset: DomainLayer.DTO.Asset
        let amount: Money
        let recipient: String
    }
    
    struct GatewayInfo {
        let assetName: String
        let assetShortName: String
        let minAmount: Money
        let maxAmount: Money
        let minAmountString: String
        let maxAmountString: String
    }
}

