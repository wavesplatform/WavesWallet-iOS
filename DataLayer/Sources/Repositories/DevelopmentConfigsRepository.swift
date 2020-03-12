//
//  ServerMaintenanceRepository.swift
//  DataLayer
//
//  Created by rprokofev on 19.11.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer
import RxSwift
import Moya

private struct DevelopmentConfigs: Decodable {
    let service_available: Bool
    let matcher_swap_timestamp: Date
    let matcher_swap_address: String
    let exchange_client_secret: String
}

public final class DevelopmentConfigsRepository: DevelopmentConfigsRepositoryProtocol {
    
    private let developmentConfigsProvider: MoyaProvider<ResourceAPI.Service.DevelopmentConfigs> = .anyMoyaProvider()
    
    public func isEnabledMaintenance() -> Observable<Bool> {
        return developmentConfigs()
            .flatMap({ (config) -> Observable<Bool> in
                return Observable.just(config.serviceAvailable == false)
            })
            .catchError({ error -> Observable<Bool> in
                return Observable.just(false)
            })            
    }
    
    public func developmentConfigs() -> Observable<DomainLayer.DTO.DevelopmentConfigs> {
        
        return developmentConfigsProvider
            .rx
            .request(.get(isDebug: ApplicationDebugSettings.isEnableDebugSettingsTest))
            .map(DevelopmentConfigs.self,
                 atKeyPath: nil,
                 using: JSONDecoder.decoderByDateWithSecond(0),
                 failsOnEmptyData: false)
            
            .asObservable()
            .map { (config) -> DomainLayer.DTO.DevelopmentConfigs in
                return DomainLayer.DTO.DevelopmentConfigs.init(serviceAvailable: config.service_available,
                                                               matcherSwapTimestamp: config.matcher_swap_timestamp,
                                                               matcherSwapAddress: config.matcher_swap_address,
                                                               exchangeClientSecret: config.exchange_client_secret)
            }
            
    }
}

