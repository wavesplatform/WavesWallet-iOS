//
//  WidgetSettingsInizializationUseCase.swift
//  DomainLayer
//
//  Created by rprokofev on 12.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift
import WavesSDK

public class WidgetSettingsInizializationUseCase: WidgetSettingsInizializationUseCaseProtocol {
    private let repositories: RepositoriesFactoryProtocol
    private let useCases: UseCasesFactoryProtocol
    private let serverEnvironmentUseCase: ServerEnvironmentRepository

    init(repositories: RepositoriesFactoryProtocol,
         useCases: UseCasesFactoryProtocol,
         serverEnvironmentUseCase: ServerEnvironmentRepository) {
        self.repositories = repositories
        self.useCases = useCases
        self.serverEnvironmentUseCase = serverEnvironmentUseCase
    }

    public func settings() -> Observable<DomainLayer.DTO.MarketPulseSettings> {
        return repositories
            .widgetSettingsStorage
            .settings()
            .flatMap { [weak self] settings -> Observable<DomainLayer.DTO.MarketPulseSettings> in

                guard let self = self else { return Observable.never() }

                if let settings = settings {
                    return Observable.just(settings)
                }

                return self.initial()
            }
    }

    private func initial() -> Observable<DomainLayer.DTO.MarketPulseSettings> {
        return repositories
            .environmentRepository
            .walletEnvironment()
            .flatMap { [weak self] walletEnviroment -> Observable<[Asset]> in

                guard let self = self else { return Observable.never() }
                let assets = walletEnviroment.generalAssets.prefix(DomainLayer.DTO.Widget.defaultCountAssets)
                return self.repositories.assetsRepositoryRemote.assets(ids: assets.map { $0.assetId },
                                                                       accountAddress: "")
                    .map { $0.compactMap { $0} }
            }
            .flatMap { [weak self] assets -> Observable<DomainLayer.DTO.MarketPulseSettings> in

                guard let self = self else { return Observable.never() }

                let pairs = assets
                    .map { DomainLayer.DTO.CorrectionPairs.Pair(amountAsset: $0.id, priceAsset: WavesSDKConstants.wavesAssetId) }

                let serverEnviroment = self.serverEnvironmentUseCase.serverEnvironment()
                let correctionPairs = self.useCases.correctionPairsUseCase.correction(pairs: pairs)

                return Observable.zip(serverEnviroment, correctionPairs)
                    .flatMap { [weak self] serverEnviroment, pairsAfterCorrection -> Observable<[DomainLayer.DTO.CorrectionPairs.Pair]> in

                        guard let self = self else { return Observable.never() }

                        let pairs: [DomainLayer.Query.Dex.SearchPairs.Pair] = pairsAfterCorrection
                            .map { .init(amountAsset: $0.amountAsset, priceAsset: $0.priceAsset) }

                        let query: DomainLayer.Query.Dex.SearchPairs = .init(kind: .pairs(pairs))

                        return self.repositories
                            .dexPairsPriceRepository
                            .searchPairs(serverEnvironment: serverEnviroment,
                                         query: query)
                            .map { _ -> [DomainLayer.DTO.CorrectionPairs.Pair] in

                                pairsAfterCorrection
                            }
                    }
                    .map { (pairs) -> DomainLayer.DTO.MarketPulseSettings in

                        let marketPulseAssets: [DomainLayer.DTO.MarketPulseSettings.Asset] = assets.enumerated()
                            .map { element -> DomainLayer.DTO.MarketPulseSettings.Asset in

                                let asset = element.element
                                let pair = pairs[element.offset]

                                return .init(id: asset.id,
                                             name: asset.displayName,
                                             icon: asset.iconLogo,
                                             amountAsset: pair.amountAsset,
                                             priceAsset: pair.priceAsset)
                            }
                        return DomainLayer.DTO.MarketPulseSettings(isDarkStyle: false,
                                                                   interval: .m10,
                                                                   assets: marketPulseAssets)
                    }
            }
    }
}
