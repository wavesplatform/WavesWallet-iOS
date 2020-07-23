//
//  ServerMaintenanceRepositoryProtocol.swift
//  DomainLayer
//
//  Created by rprokofev on 19.11.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift


public struct DevelopmentConfigs {
    
    public struct Staking {
        public let type: String
        public let neutrinoAssetId: String
        public let addressByPayoutsAnnualPercent: String
        public let addressStakingContract: String
        public let addressByCalculateProfit: String
        public let addressesByPayoutsAnnualPercent: [String]
        
        /// Количество шаринга в процентах        
        public let referralShare: Int64
        
        public init(type: String,
                    neutrinoAssetId: String,
                    addressByPayoutsAnnualPercent: String,
                    addressStakingContract: String,
                    addressByCalculateProfit: String,
                    addressesByPayoutsAnnualPercent: [String],
                    referralShare: Int64) {
            self.type = type
            self.neutrinoAssetId = neutrinoAssetId
            self.addressByPayoutsAnnualPercent = addressByPayoutsAnnualPercent
            self.addressStakingContract = addressStakingContract
            self.addressByCalculateProfit = addressByCalculateProfit
            self.addressesByPayoutsAnnualPercent = addressesByPayoutsAnnualPercent
            self.referralShare = referralShare
        }
    }
    
    public struct Rate: Decodable {
        public let rate: Double
        public let flat: Int64

        public init(rate: Double, flat: Int64) {
            self.rate = rate
            self.flat = flat
        }
    }
    
    public struct Limit: Decodable {
        public let min: Int64
        public let max: Int64

        public init(min: Int64, max: Int64) {
            self.min = min
            self.max = max
        }
    }
    
    public struct MarketPair {
        public let amount: String
        public let price: String
        
        public init(amount: String, price: String) {
            self.amount = amount
            self.price = price
        }
    }

    public let serviceAvailable: Bool
    public let matcherSwapTimestamp: Date
    public let matcherSwapAddress: String
    public let exchangeClientSecret: String
    public let staking: [Staking]
    // List assetId when lock
    public let lockedPairs: [String]
    

    // First key is assetId and second key is fiat
    // For example: value["DG2xFkPdDwKUoBkzGAhQtLpSGzfXLiCYPEzeKH2Ad24p"]["usn"]
    public let gatewayMinFee: [String: [String: Rate]]
    
    // First key is gateway id
    // For example: value["BTC"]
    public let gatewayMinLimit: [String: Limit]

    // Список ассетов доступны для покупки в multy currency
    public let avaliableGatewayCryptoCurrency: [String]
    
    /// Список пар, обмен на которые возможен
    public let marketPairs: [MarketPair]
    
    public init(serviceAvailable: Bool,
                matcherSwapTimestamp: Date,
                matcherSwapAddress: String,
                exchangeClientSecret: String,
                staking: [Staking],
                lockedPairs: [String],
                gatewayMinFee: [String: [String: Rate]],
                marketPairs: [MarketPair],
                gatewayMinLimit: [String: Limit],
                avaliableGatewayCryptoCurrency: [String]) {
        self.serviceAvailable = serviceAvailable
        self.matcherSwapAddress = matcherSwapAddress
        self.matcherSwapTimestamp = matcherSwapTimestamp
        self.exchangeClientSecret = exchangeClientSecret
        self.staking = staking
        self.lockedPairs = lockedPairs
        self.gatewayMinFee = gatewayMinFee
        self.marketPairs = marketPairs
        self.gatewayMinLimit = gatewayMinLimit
        self.avaliableGatewayCryptoCurrency = avaliableGatewayCryptoCurrency
    }
}

public protocol DevelopmentConfigsRepositoryProtocol {

    func isEnabledMaintenance() -> Observable<Bool>
    
    func developmentConfigs() -> Observable<DevelopmentConfigs>
}
