//
//  DexSellBuyTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/8/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

private enum Constansts {
    static let orderFee = 300000
}

enum DexCreateOrder {
    enum DTO {}
    enum ViewModel {}
    
    enum Event {
        case createOrder
        case orderDidCreate(ResponseType<DTO.Output>)
        case updateInputOrder(DTO.Order)
    }
    
    struct State: Mutating {
        enum Action {
            case none
            case showCreatingOrderState
            case orderDidFailCreate(NetworkError)
            case orderDidCreate
        }
        
        var isNeedCreateOrder: Bool
        var order: DTO.Order?
        var action: Action
    }
}

extension DexCreateOrder.DTO {
  
    enum Expiration: Int {
        case expiration5m = 5
        case expiration30m = 30
        case expiration1h = 60
        case expiration1d = 1440
        case expiration1w = 10080
        case expiration29d = 41760
    }
    
    struct Input {
        let amountAsset: DomainLayer.DTO.Dex.Asset
        let priceAsset: DomainLayer.DTO.Dex.Asset
        let type: DomainLayer.DTO.Dex.OrderType
        let price: Money?
        let ask: Money?
        let bid: Money?
        let last: Money?
        let availableAmountAssetBalance: Money
        let availablePriceAssetBalance: Money
        let availableWavesBalance: Money
        let inputMaxAmount: Bool
    }
    
    struct Order {
        let amountAsset: DomainLayer.DTO.Dex.Asset
        let priceAsset: DomainLayer.DTO.Dex.Asset
        var type: DomainLayer.DTO.Dex.OrderType
        var amount: Money
        var price: Money
        var total: Money
        var expiration: Expiration
        let fee: Int = Constansts.orderFee
        
        init(amountAsset: DomainLayer.DTO.Dex.Asset, priceAsset: DomainLayer.DTO.Dex.Asset, type: DomainLayer.DTO.Dex.OrderType, amount: Money, price: Money, total: Money, expiration: Expiration) {
            
            self.amountAsset = amountAsset
            self.priceAsset = priceAsset
            self.type = type
            self.amount = amount
            self.price = price
            self.total = total
            self.expiration = expiration
        }
    }
    
    struct Output {
        let time: Date
        let orderType: DomainLayer.DTO.Dex.OrderType
        let price: Money
        let amount: Money
    }
}


extension DexCreateOrder.DTO.Expiration {
    
    var text: String {
        switch self {
        case .expiration5m:
            return "5" + " " + Localizable.Waves.Dexcreateorder.Button.minutes
            
        case .expiration30m:
            return "30" + " " + Localizable.Waves.Dexcreateorder.Button.minutes
            
        case .expiration1h:
            return "1" + " " + Localizable.Waves.Dexcreateorder.Button.hour
            
        case .expiration1d:
            return "1" + " " + Localizable.Waves.Dexcreateorder.Button.day
            
        case .expiration1w:
            return "1" + " " + Localizable.Waves.Dexcreateorder.Button.week
            
        case .expiration29d:
            return "29" + " " + Localizable.Waves.Dexcreateorder.Button.days
        }
    }
}

extension DomainLayer.DTO.Dex.OrderType {
    var bytes: [UInt8] {
        switch self {
        case .sell: return [UInt8(1)]
        case .buy: return [UInt8(0)]
        }
    }
}
