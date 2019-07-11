//
//  DexSellBuyTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/8/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDK
import Extensions
import DomainLayer

enum DexCreateOrder {
    enum DTO {}
    enum ViewModel {}
    
    enum Event {
        case createOrder
        case sendOrder
        case cancelCreateOrder
        case orderDidCreate(ResponseType<DTO.Output>)
        case updateInputOrder(DTO.Order)
        case didGetFee(DTO.FeeSettings)
        case orderNotValid(DexCreateOrder.CreateOrderError)
        case handlerFeeError(Error)
        case refreshFee
        case feeAssetNeedUpdate(String)
    }
    
    enum CreateOrderError: Error {
        case invalid
        case priceLowerMarket
        case priceHigherMarket
    }
    
    struct State: Mutating {
        enum Action {
            case none
            case showDeffaultOrderState
            case showCreatingOrderState
            case orderDidFailCreate(NetworkError)
            case orderNotValid(DexCreateOrder.CreateOrderError)
            case orderDidCreate(DexCreateOrder.DTO.Output)
            case didGetFee(DTO.FeeSettings)
        }
        
        var isNeedCreateOrder: Bool
        var isNeedCheckValidOrder: Bool
        var isNeedGetFee: Bool
        var order: DTO.Order?
        var action: Action
        var displayFeeErrorState: DisplayErrorState
        var isDisabledSellBuyButton: Bool
        var feeAssetId: String
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
        let sum: Money?
        let ask: Money?
        let bid: Money?
        let last: Money?
        let availableAmountAssetBalance: Money
        let availablePriceAssetBalance: Money
        let availableWavesBalance: Money
    }
    
    struct Order {
        let amountAsset: DomainLayer.DTO.Dex.Asset
        let priceAsset: DomainLayer.DTO.Dex.Asset
        var type: DomainLayer.DTO.Dex.OrderType
        var amount: Money
        var price: Money
        var total: Money
        var expiration: Expiration
        var fee: Int64
        var feeAssetId: String
        
        init(amountAsset: DomainLayer.DTO.Dex.Asset, priceAsset: DomainLayer.DTO.Dex.Asset, type: DomainLayer.DTO.Dex.OrderType, amount: Money, price: Money, total: Money, expiration: Expiration, fee: Int64, feeAssetId: String) {
            
            self.amountAsset = amountAsset
            self.priceAsset = priceAsset
            self.type = type
            self.amount = amount
            self.price = price
            self.total = total
            self.expiration = expiration
            self.fee = fee
            self.feeAssetId = feeAssetId
        }
    }
    
    struct Output {
        let time: Date
        let orderType: DomainLayer.DTO.Dex.OrderType
        let price: Money
        let amount: Money
    }
    
    struct FeeSettings {
        let fee: Money
        let feeAssets: [DomainLayer.DTO.Dex.SmartSettingsOrderFee.Asset]
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

extension DexCreateOrder.State: Equatable {
    
    static func == (lhs: DexCreateOrder.State, rhs: DexCreateOrder.State) -> Bool {
        return lhs.isNeedCreateOrder == rhs.isNeedCreateOrder &&
            lhs.isNeedGetFee == rhs.isNeedGetFee
    }
}
