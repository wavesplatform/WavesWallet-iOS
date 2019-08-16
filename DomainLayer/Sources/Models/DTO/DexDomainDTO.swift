//
//  DexTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/12/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Extensions

public extension DomainLayer.DTO {
    enum Dex {}
}

//MARK: Asset
public extension DomainLayer.DTO.Dex {
    
    struct Asset {
        public let id: String
        public let name: String
        public let shortName: String
        public let decimals: Int

        public init(id: String, name: String, shortName: String, decimals: Int) {
            self.id = id
            self.name = name
            self.shortName = shortName
            self.decimals = decimals
        }
    }
    
    enum OrderType: String {
        case sell
        case buy
    }
}

//MARK: LastTrade
public extension DomainLayer.DTO.Dex {
    
    struct LastTrade {
        public let time: Date
        public let price: Money
        public let amount: Money
        public let sum: Money
        public let type: OrderType

        public init(time: Date, price: Money, amount: Money, sum: Money, type: OrderType) {
            self.time = time
            self.price = price
            self.amount = amount
            self.sum = sum
            self.type = type
        }
    }
}

//MARK: - SmartPair
public extension DomainLayer.DTO.Dex {
    
    struct SmartPair: Mutating {
        public let id: String
        public let amountAsset: Asset
        public let priceAsset: Asset
        public var isChecked: Bool
        public let isGeneral: Bool
        public var sortLevel: Int

        public init(id: String, amountAsset: Asset, priceAsset: Asset, isChecked: Bool, isGeneral: Bool, sortLevel: Int) {
            self.id = id
            self.amountAsset = amountAsset
            self.priceAsset = priceAsset
            self.isChecked = isChecked
            self.isGeneral = isGeneral
            self.sortLevel = sortLevel
        }
    }
}

//MARK: - SimplePair
public extension DomainLayer.DTO.Dex {
    
    struct SimplePair {
        public let amountAsset: String
        public let priceAsset: String
        
        public init(amountAsset: String, priceAsset: String) {
            self.amountAsset = amountAsset
            self.priceAsset = priceAsset
        }
    }
}


//MARK: - Pair
public extension DomainLayer.DTO.Dex {
    
    struct Pair {
        public let amountAsset: Asset
        public let priceAsset: Asset

        public init(amountAsset: Asset, priceAsset: Asset) {
            self.amountAsset = amountAsset
            self.priceAsset = priceAsset
        }
    }
    
    
    struct PairsSearch {
        
        public struct Pair {
            public let firstPrice: Double
            public let lastPrice: Double
            public let volume: Double
            public let volumeWaves: Double?
            public let quoteVolume: Double?

            public init(firstPrice: Double, lastPrice: Double, volume: Double, volumeWaves: Double?, quoteVolume: Double?) {
                self.firstPrice = firstPrice
                self.lastPrice = lastPrice
                self.volume = volume
                self.volumeWaves = volumeWaves
                self.quoteVolume = quoteVolume
            }
        }
        
        public let pairs: [Pair?]
        
        public init(pairs: [Pair?]) {
            self.pairs = pairs
        }
    }
    
}

//MARK: - PairPrice
public extension DomainLayer.DTO.Dex {
    struct PairPrice {
        public let firstPrice: Money
        public let lastPrice: Money
        public let amountAsset: Asset
        public let priceAsset: Asset

        public init(firstPrice: Money, lastPrice: Money, amountAsset: Asset, priceAsset: Asset) {
            self.firstPrice = firstPrice
            self.lastPrice = lastPrice
            self.amountAsset = amountAsset
            self.priceAsset = priceAsset
        }
    }
}

//MARK: - MyOrder

public extension DomainLayer.DTO.Dex {
    
    struct MyOrder {
        
        public enum Status {
            case accepted
            case partiallyFilled
            case cancelled
            case filled
        }
        
        public let id: String
        public let time: Date
        public var status: Status
        public let price: Money
        public let amount: Money
        public let filled: Money
        public let type: OrderType
        public let amountAsset: Asset
        public let priceAsset: Asset
        public let percentFilled: Int
        public let fee: Int64?
        public let feeAsset: String?

        public init(id: String, time: Date, status: Status, price: Money, amount: Money, filled: Money, type: OrderType, amountAsset: Asset, priceAsset: Asset, percentFilled: Int, fee: Int64?, feeAsset: String?) {
            self.fee = fee
            self.feeAsset = feeAsset
            self.id = id
            self.time = time
            self.status = status
            self.price = price
            self.amount = amount
            self.filled = filled
            self.type = type
            self.amountAsset = amountAsset
            self.priceAsset = priceAsset
            self.percentFilled = percentFilled
        }
    }
}

//MARK: - OrderBook
public extension DomainLayer.DTO.Dex {
    
    struct OrderBook {
        
        public struct Value {
            public let amount: Int64
            public let price: Int64

            public init(amount: Int64, price: Int64) {
                self.amount = amount
                self.price = price
            }
        }
        
        public let bids: [Value]
        public let asks: [Value]

        public init(bids: [Value], asks: [Value]) {
            self.bids = bids
            self.asks = asks
        }
    }
}


//MARK: - SettingsOrderFee

public extension DomainLayer.DTO.Dex {

    struct SettingsOrderFee {
        
        public struct Asset {
            public let assetId: String
            public let rate: Double
            
            public init(assetId: String, rate: Double) {
                self.assetId = assetId
                self.rate = rate
            }
        }
        
        public let baseFee: Int64
        public let feeAssets: [Asset]
        
        public init(baseFee: Int64, feeAssets: [Asset]) {
            self.baseFee = baseFee
            self.feeAssets = feeAssets
        }
    }
}

//MARK: - SmartSettingsOrderFee

public extension DomainLayer.DTO.Dex {
    
    struct SmartSettingsOrderFee {
        
        public struct Asset {
            public let rate: Double
            public let asset: DomainLayer.DTO.Dex.Asset
            
            public init(rate: Double, asset: DomainLayer.DTO.Dex.Asset) {
                self.rate = rate
                self.asset = asset
            }
        }
        
        public let baseFee: Int64
        public let feeAssets: [Asset]
    }
}
