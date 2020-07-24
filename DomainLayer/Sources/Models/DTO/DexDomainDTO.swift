//
//  DexTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/12/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Extensions
import Foundation

public extension DomainLayer.DTO {
    enum Dex {}
}

// MARK: Asset

public extension DomainLayer.DTO.Dex {

    enum OrderType: String {
        case sell
        case buy
    }
}

// MARK: LastTrade

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

// MARK: - FavoritePair

public extension DomainLayer.DTO.Dex {
    struct FavoritePair: Equatable {
        public let id: String
        public let amountAssetId: String
        public let priceAssetId: String
        public let isGeneral: Bool
        public var sortLevel: Int

        public init(id: String, amountAssetId: String, priceAssetId: String, isGeneral: Bool, sortLevel: Int) {
            self.id = id
            self.amountAssetId = amountAssetId
            self.priceAssetId = priceAssetId
            self.isGeneral = isGeneral
            self.sortLevel = sortLevel
        }
    }
}

// MARK: - SavePair

public extension DomainLayer.DTO.Dex {
    struct SavePair {
        public let id: String
        public let isGeneral: Bool
        public let amountAsset: Asset
        public let priceAsset: Asset

        public init(id: String, isGeneral: Bool, amountAsset: Asset, priceAsset: Asset) {
            self.id = id
            self.isGeneral = isGeneral
            self.amountAsset = amountAsset
            self.priceAsset = priceAsset
        }
    }
}

// MARK: - SmartPair

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

// TODO: Refactor SimplePair
public extension DomainLayer.DTO.Dex {
    struct SimplePair: Equatable, Hashable {
        public let amountAsset: String
        public let priceAsset: String

        public init(amountAsset: String, priceAsset: String) {
            self.amountAsset = amountAsset
            self.priceAsset = priceAsset
        }
    }
}

// MARK: - Pair

public extension DomainLayer.DTO.Dex {
    struct Pair {
        public let amountAsset: Asset
        public let priceAsset: Asset

        public init(amountAsset: Asset, priceAsset: Asset) {
            self.amountAsset = amountAsset
            self.priceAsset = priceAsset
        }

        public var id: String {
            return amountAsset.id + priceAsset.id
        }
    }

    // TODO: Refactor (Очень много разлчных моделей для пар)
    /*

     Когда идет запрос в DataService на получение пар по
     pairs=_amountAsset/priceAsset
     searchByAsset(searchKey)
     searchByAssets(amountAsset/priceAsset)

     то DataService выдает разную структуру ответа
     */

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

// MARK: - PairPrice

public extension DomainLayer.DTO.Dex {
    struct PairPrice {
        public let id: String
        public let firstPrice: Money
        public let lastPrice: Money
        public let amountAsset: Asset
        public let priceAsset: Asset
        public let isGeneral: Bool
        public let volumeWaves: Double

        public init(
            firstPrice: Money,
            lastPrice: Money,
            amountAsset: Asset,
            priceAsset: Asset,
            isGeneral: Bool,
            volumeWaves: Double) {
            id = amountAsset.id + priceAsset.id
            self.firstPrice = firstPrice
            self.lastPrice = lastPrice
            self.amountAsset = amountAsset
            self.priceAsset = priceAsset
            self.isGeneral = isGeneral
            self.volumeWaves = volumeWaves
        }
    }
}

// MARK: - PairRate

public extension DomainLayer.DTO.Dex {
    struct PairRate {
        public let amountAssetId: String
        public let priceAssetId: String
        public let rate: Double

        public init(amountAssetId: String, priceAssetId: String, rate: Double) {
            self.amountAssetId = amountAssetId
            self.priceAssetId = priceAssetId
            self.rate = rate
        }
    }
}

// MARK: - MyOrder

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
        public let fee: Int64?
        public let feeAsset: String?

        public init(
            id: String,
            time: Date,
            status: Status,
            price: Money,
            amount: Money,
            filled: Money,
            type: OrderType,
            amountAsset: Asset,
            priceAsset: Asset,
            fee: Int64?,
            feeAsset: String?) {
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
        }

        public var filledPercent: Int {
            let roundedPercent = ceil(filled.doubleValue * 100 / amount.doubleValue)
            return min(100, Int(roundedPercent))
        }
    }
}

// MARK: - OrderBook

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

// MARK: - SettingsOrderFee

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

// MARK: - SmartSettingsOrderFee

public extension DomainLayer.DTO.Dex {
    struct SmartSettingsOrderFee {
        public struct FeeAsset {
            public let rate: Double
            public let asset: Asset

            public init(rate: Double, asset: Asset) {
                self.rate = rate
                self.asset = asset
            }
        }

        public let baseFee: Int64
        public let feeAssets: [FeeAsset]
    }
}
