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
        case getUSDAmountInfo
        case getEURAmountInfo
    }
    
    struct State: Mutating {
        enum Action {
            case none
            case didGetInfo
            case didFailGetInfo(Error)
        }

        var fiatType: DTO.FiatType
        var action: Action
        var link: String = ""
        var amountUSDInfo: DTO.AmountInfo?
        var amountEURInfo: DTO.AmountInfo?
        var assetBalance: DomainLayer.DTO.AssetBalance?
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
    
    struct AmountInfo {
        let type: FiatType
        let minAmount: Money
        let maxAmount: Money
        let minAmountString: String
        let maxAmountString: String
    }
    
    struct Info {
        let asset: DomainLayer.DTO.AssetBalance
        let amountInfo : AmountInfo
    }
}

extension ReceiveCard.DTO.FiatType {
    
    var id: String {
        switch self {
        case .eur:
            return "EURO"
            
        case .usd:
            return "USD"
        }
    }
    
    var text: String {
        switch self {
        case .eur:
            return "EUR"
        
        case .usd:
            return "USD"
        }
    }
}

extension ReceiveCard.DTO.AmountInfo: Equatable {
    static func == (lhs: ReceiveCard.DTO.AmountInfo, rhs: ReceiveCard.DTO.AmountInfo) -> Bool {
        return lhs.type == rhs.type &&
        lhs.minAmount == rhs.minAmount &&
        lhs.maxAmount == rhs.maxAmount &&
        lhs.minAmountString == rhs.minAmountString &&
        lhs.maxAmountString == rhs.maxAmountString
    }
}

extension ReceiveCard.State: Equatable {
    
    static func == (lhs: ReceiveCard.State, rhs: ReceiveCard.State) -> Bool {

        return lhs.fiatType == rhs.fiatType &&
            lhs.link == rhs.link &&
            lhs.amountUSDInfo == rhs.amountUSDInfo &&
            lhs.amountEURInfo == rhs.amountEURInfo
    }
}
