//
//  TradeCategoriesConfigRepository.swift
//  DataLayer
//
//  Created by Pavel Gubin on 16.01.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import DomainLayer
import Moya
import Extensions

private enum Response {
    
    struct TradeCategory: Decodable {
        
        struct Filter: Decodable {
            let title: [String: String]
            let assetIds: [String]
        }
        
        struct Pair: Decodable {
            let amountId: String
            let priceId: String
        }
        
        let name: [String: String]
        let filters: [Filter]
        let pairs: [Pair]
    }
}

final class TradeCategoriesConfigRepository: TradeCategoriesConfigRepositoryProtocol {
  
    private let categoriesConfigProvider: MoyaProvider<ResourceAPI.Service.TradeCategoriesConfig> = .anyMoyaProvider()
    private let assetsRepoitory: AssetsRepositoryProtocol

    init(assetsRepoitory: AssetsRepositoryProtocol) {
        self.assetsRepoitory = assetsRepoitory
    }
    
    func tradeCagegories(accountAddress: String) -> Observable<[DomainLayer.DTO.TradeCategory]> {
     
        return categoriesConfigProvider.rx
            .request(.get(isDebug: ApplicationDebugSettings.isEnableVersionUpdateTest),
                     callbackQueue:  DispatchQueue.global(qos: .userInteractive))
            .map([Response.TradeCategory].self)
            .asObservable()
            .flatMap { [weak self] (categories) -> Observable<[DomainLayer.DTO.TradeCategory]> in
                guard let self = self else { return Observable.empty() }
                
                var assetsIds: [String] = []
                for category in categories {
                    for pair in category.pairs {
                        
                        if !assetsIds.contains(pair.amountId) {
                            assetsIds.append(pair.amountId)
                        }
                        
                        if !assetsIds.contains(pair.priceId) {
                            assetsIds.append(pair.priceId)
                        }
                    }
                }
                
                return self.assetsRepoitory.assets(by: assetsIds, accountAddress: accountAddress)
                    .map { (assets) -> [DomainLayer.DTO.TradeCategory] in
                 
                        let lang = Language.currentLanguage.code
                        let defaultLang = Language.defaultLanguage.code

                        return categories.map {
                        
                            let name = $0.name[lang] ?? ($0.name[defaultLang] ?? "")
                            
                            let filters: [DomainLayer.DTO.TradeCategory.Filter] = $0.filters.map {
                                return .init(name: $0.title[lang] ?? ($0.title[defaultLang] ?? ""),
                                             ids: $0.assetIds)
                                
                            }
                            
                            let pairs = $0.pairs.map { pair -> DomainLayer.DTO.Dex.Pair in
                                
                                let amountAsset = assets.first(where: {$0.id == pair.amountId})!
                                let priceAsset = assets.first(where: {$0.id == pair.priceId})!
                                
                                return DomainLayer.DTO.Dex.Pair(amountAsset: .init(id: amountAsset.id,
                                                                                   name: amountAsset.displayName,
                                                                                   shortName: amountAsset.ticker ?? amountAsset.displayName,
                                                                                   decimals: amountAsset.precision,
                                                                                   iconLogo: amountAsset.iconLogo),
                                                                
                                                                priceAsset: .init(id: priceAsset.id,
                                                                                  name: priceAsset.displayName,
                                                                                  shortName: priceAsset.ticker ?? priceAsset.displayName,
                                                                                  decimals: priceAsset.precision,
                                                                                  iconLogo: priceAsset.iconLogo))
                            }
                            
                            return DomainLayer.DTO.TradeCategory(name: name, filters: filters, pairs: pairs)
                        }
                }
        }
    }
}
