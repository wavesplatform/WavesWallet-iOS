//
//  WidgetAssetsRepositoryRemote.swift
//  MarketPulseWidget
//
//  Created by Pavel Gubin on 28.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer
import RxSwift

protocol WidgetAssetsRepositoryProtocol {
    func assets(by ids: [String]) -> Observable<[DomainLayer.DTO.Asset]>
}

final class WidgetAssetsRepositoryRemote {
    
    public func assets(by ids: [String]) -> Observable<[DomainLayer.DTO.Asset]> {
        
        return Observable.empty()
//        return environmentRepository
//            .servicesEnvironment()
//            .flatMap({ [weak self] (servicesEnvironment) -> Observable<[DomainLayer.DTO.Asset]> in
//                
//                guard let self = self else { return Observable.empty() }
//                
//                let walletEnviroment = servicesEnvironment.walletEnvironment
//                
//                let spamAssets = self
//                    .spamAssetsRepository
//                    .spamAssets(accountAddress: accountAddress)
//                
//                let assetsList = servicesEnvironment
//                    .wavesServices
//                    .dataServices
//                    .assetsDataService
//                    .assets(ids: ids)
//                
//                return Observable.zip(assetsList, spamAssets)
//                    .map({ (assets, spamAssets) -> [DomainLayer.DTO.Asset] in
//                        
//                        let map = walletEnviroment.hashMapAssets()
//                        let mapGeneralAssets = walletEnviroment.hashMapGeneralAssets()
//                        
//                        let spamIds = spamAssets.reduce(into: [String: Bool](), {$0[$1] = true })
//                        
//                        return assets.map { DomainLayer.DTO.Asset(asset: $0,
//                                                                  info: map[$0.id],
//                                                                  isSpam: spamIds[$0.id] == true,
//                                                                  isMyWavesToken: $0.sender == accountAddress,
//                                                                  isGeneral: mapGeneralAssets[$0.id] != nil) }
//                    })
//            })
    }
}
