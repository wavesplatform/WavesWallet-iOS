//
//  ServerMaintenanceRepositoryProtocol.swift
//  DomainLayer
//
//  Created by rprokofev on 19.11.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

public extension DomainLayer.DTO {
    
    struct DevelopmentConfigs {
        public let serviceAvailable: Bool
        public let matcherSwapTimestamp: Date
        public let matcherSwapAddress: String
        public let exchangeClientSecret: String
        public let staking: [Staking]

        public init(serviceAvailable: Bool,
                    matcherSwapTimestamp: Date,
                    matcherSwapAddress: String,
                    exchangeClientSecret: String,
                    staking: [Staking]) {
            self.serviceAvailable = serviceAvailable
            self.matcherSwapAddress = matcherSwapAddress
            self.matcherSwapTimestamp = matcherSwapTimestamp
            self.exchangeClientSecret = exchangeClientSecret
            self.staking = staking
        }
    }
}

public extension DomainLayer.DTO {
    struct Staking {
        public let type: String
        public let neutrinoAssetId: String
        public let addressByPayoutsAnnualPercent: String
        public let addressStakingContract: String
        public let addressByCalculateProfit: String
        
        public init(type: String,
                    neutrinoAssetId: String,
                    addressByPayoutsAnnualPercent: String,
                    addressStakingContract: String,
                    addressByCalculateProfit: String) {
            self.type = type
            self.neutrinoAssetId = neutrinoAssetId
            self.addressByPayoutsAnnualPercent = addressByPayoutsAnnualPercent
            self.addressStakingContract = addressStakingContract
            self.addressByCalculateProfit = addressByCalculateProfit
        }
    }
}

public protocol DevelopmentConfigsRepositoryProtocol {

    func isEnabledMaintenance() -> Observable<Bool>
    
    func developmentConfigs() -> Observable<DomainLayer.DTO.DevelopmentConfigs>
}


