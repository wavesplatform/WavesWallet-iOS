//
//  ReceiveCardTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/7/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum ReceiveCard {
    enum DTO {}
    
    enum Event {
        case didGetInfo(Responce<DTO.Info>)
    }
    
    struct State: Mutating {
        enum Action {
            case none
            case didGetInfo(DTO.Info)
            case didFailGetInfo(Error)
        }

        var info: DTO.Info?
        var action: Action
    }
}

extension ReceiveCard.DTO {

    enum FiatType {
        case usd
        case eur
    }
    
    struct Order {
        let asset: DomainLayer.DTO.AssetBalance
        let amount: Money
        let fiatType: FiatType
    }
    
    struct Info {
        let minimumAmount: Money
        let maximumAmount: Money
    }
}

extension ReceiveCard.DTO.FiatType {
    
    var text: String {
        switch self {
        case .eur:
            return "EUR"
        
        case .usd:
            return "USD"
        }
    }
}
