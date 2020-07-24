//
//  TradeCategoriesConfigRepository.swift
//  DataLayer
//
//  Created by Pavel Gubin on 16.01.2020.
//  Copyright © 2020 Waves.Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import Moya
import RxSwift

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
        let matching_assets: [String]
    }
}

final class TradeCategoriesConfigRepository: TradeCategoriesConfigRepositoryProtocol {
    private let categoriesConfigProvider: MoyaProvider<ResourceAPI.Service.TradeCategoriesConfig> = .anyMoyaProvider()
    private let assetsRepoitory: AssetsRepositoryProtocol

    init(assetsRepoitory: AssetsRepositoryProtocol) {
        self.assetsRepoitory = assetsRepoitory
    }

    func tradeCagegories(serverEnvironment: ServerEnvironment,
                         accountAddress: String) -> Observable<[DomainLayer.DTO.TradeCategory]> {
        return categoriesConfigProvider.rx
            .request(.get(isTest: ApplicationDebugSettings.isEnableEnviromentTest,
                          kind: serverEnvironment.kind),
                     callbackQueue: DispatchQueue.global(qos: .userInteractive))
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

                    category.matching_assets.forEach { assetId in
                        if !assetsIds.contains(assetId) {
                            assetsIds.append(assetId)
                        }
                    }
                }

                return self
                    .assetsRepoitory
                    .assets(ids: assetsIds,
                            accountAddress: accountAddress)
                    .map { $0.compactMap { $0 } }
                    .map { (assets) -> [DomainLayer.DTO.TradeCategory] in
                        let lang = Language.currentLanguage.code
                        let defaultLang = Language.defaultLanguage.code

                        let assetsMap = assets.reduce(into: [String: Asset].init()) { $0[$1.id] = $1 }

                        return categories.map {
                            let name = $0.name[lang] ?? ($0.name[defaultLang] ?? "")

                            let filters: [DomainLayer.DTO.TradeCategory.Filter] = $0.filters.map {
                                .init(name: $0.title[lang] ?? ($0.title[defaultLang] ?? ""),
                                      ids: $0.assetIds)
                            }

                            let pairs = $0.pairs.map { pair -> DomainLayer.DTO.Dex.Pair? in

                                guard let amountAsset = assetsMap[pair.amountId] else { return nil }
                                guard let priceAsset = assetsMap[pair.priceId] else { return nil }

                                return DomainLayer.DTO.Dex.Pair(amountAsset: amountAsset,
                                                                priceAsset: priceAsset)
                            }
                            .compactMap { $0 }

                            let matchingAassets = $0.matching_assets
                                .map { assetsMap[$0] }
                                .compactMap { $0 }
                                .map { $0 }

                            return DomainLayer.DTO.TradeCategory(name: name,
                                                                 filters: filters,
                                                                 pairs: pairs,
                                                                 matchingAssets: matchingAassets)
                        }
                    }
            }
    }
}
