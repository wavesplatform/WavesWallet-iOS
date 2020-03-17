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

        public init(serviceAvailable: Bool,
                    matcherSwapTimestamp: Date,
                    matcherSwapAddress: String,
                    exchangeClientSecret: String) {
            self.serviceAvailable = serviceAvailable
            self.matcherSwapAddress = matcherSwapAddress
            self.matcherSwapTimestamp = matcherSwapTimestamp
            self.exchangeClientSecret = exchangeClientSecret
        }
    }
}

public protocol DevelopmentConfigsRepositoryProtocol {

    func isEnabledMaintenance() -> Observable<Bool>
    
    func developmentConfigs() -> Observable<DomainLayer.DTO.DevelopmentConfigs>
}


