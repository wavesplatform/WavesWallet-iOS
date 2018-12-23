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
        case didGetInfo(ResponseType<DTO.Info>)
        case getUSDAmountInfo
        case getEURAmountInfo
        case updateAmount(Money)
        case didGetPriceInfo(ResponseType<Money>)
        case updateAmountWithUSDFiat
        case updateAmountWithEURFiat
    }
    
    struct State: Mutating {
        enum Action {
            case none
            case didGetInfo
            case didFailGetInfo(NetworkError)
            case changeUrl
            case didGetWavesAmount(Money)
            case didFailGetWavesAmount(NetworkError)
        }

        var isNeedLoadInfo: Bool
        var isNeedLoadPriceInfo: Bool
        var fiatType: DTO.FiatType
        var action: Action
        var link: String = ""
        var amountUSDInfo: DTO.AmountInfo?
        var amountEURInfo: DTO.AmountInfo?
        var assetBalance: DomainLayer.DTO.SmartAssetBalance?
        var amount: Money?
        var address: String = ""
    }
}

extension ReceiveCard.DTO {
    
    static var fiatDecimals: Int {
        return 2
    }
    
    enum FiatType {
        case usd
        case eur
    }
    
    struct Order {
        let asset: DomainLayer.DTO.SmartAssetBalance
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
        let asset: DomainLayer.DTO.SmartAssetBalance
        let amountInfo : AmountInfo
        let address: String
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


extension ReceiveCard.State: Equatable {
    
    static func == (lhs: ReceiveCard.State, rhs: ReceiveCard.State) -> Bool {
        return lhs.isNeedLoadInfo == rhs.isNeedLoadInfo &&
            lhs.isNeedLoadPriceInfo == rhs.isNeedLoadPriceInfo &&
            lhs.fiatType == rhs.fiatType &&
            lhs.amount == rhs.amount
    }
}

