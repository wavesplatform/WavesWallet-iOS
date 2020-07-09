//
//  MarketPulseWidgetInteractor.swift
//  MarketPulseWidget
//
//  Created by Pavel Gubin on 24.07.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import DomainLayer
import DataLayer
import Extensions
import Foundation
import RxSwift
import WavesSDK
import WavesSDKExtensions

private enum Constants {
    static let exchangeTxLimit: Int = 5
}

protocol MarketPulseWidgetInteractorProtocol {
    func assets() -> Observable<[MarketPulse.DTO.Asset]>
    func chachedAssets() -> Observable<[MarketPulse.DTO.Asset]>
    func settings() -> Observable<MarketPulse.DTO.Settings>
}

final class MarketPulseWidgetInteractor: MarketPulseWidgetInteractorProtocol {
    private lazy var environmentRepository: EnvironmentRepositoryProtocol = EnvironmentRepository()
    private lazy var widgetSettingsRepository: WidgetSettingsInizializationUseCaseProtocol = WidgetSettingsInizialization(environmentRepository: self.environmentRepository)
    private lazy var pairsPriceRepository = WidgetPairsPriceRepositoryRemote(environmentRepository: environmentRepository)
    private let dbRepository: MarketPulseDataBaseRepositoryProtocol = MarketPulseDataBaseRepository()
    private lazy var assetsRepository: WidgetAssetsRepositoryProtocol =
        WidgetAssetsRepositoryRemote(environmentRepository: environmentRepository)

    init() {
        _ = setupLayers()
    }

    static var shared = MarketPulseWidgetInteractor()

    private func setupLayers() -> Bool {
        guard let googleServiceInfoPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else {
            return false
        }

        guard let appsflyerInfoPath = Bundle.main.path(forResource: "Appsflyer-Info", ofType: "plist") else {
            return false
        }

        guard let amplitudeInfoPath = Bundle.main.path(forResource: "Amplitude-Info", ofType: "plist") else {
            return false
        }

        WidgetAnalyticManagerInitialization.setup(resources: .init(googleServiceInfo: googleServiceInfoPath,
                                                                   appsflyerInfo: appsflyerInfoPath,
                                                                   amplitudeInfo: amplitudeInfoPath))

        return true
    }

    func settings() -> Observable<MarketPulse.DTO.Settings> {
        Observable.zip(WidgetSettings.rx.currency(), widgetSettingsRepository.settings())
            .flatMap { currency, marketPulseSettings -> Observable<MarketPulse.DTO.Settings> in
                Observable.just(MarketPulse.DTO.Settings(currency: currency,
                                                         isDarkMode: marketPulseSettings.isDarkStyle,
                                                         inverval: marketPulseSettings.interval))
            }
    }

    func chachedAssets() -> Observable<[MarketPulse.DTO.Asset]> { dbRepository.chachedAssets() }

    func assets() -> Observable<[MarketPulse.DTO.Asset]> {
        widgetSettingsRepository.settings()
            .flatMap { [weak self] settings -> Observable<[MarketPulse.DTO.Asset]> in
                guard let self = self else { return Observable.empty() }
                return self.loadAssets(assets: settings.assets)
            }
    }

    private func loadAssets(assets: [DomainLayer.DTO.MarketPulseSettings.Asset]) -> Observable<[MarketPulse.DTO.Asset]> {
        let earlyDate = Calendar.current.date(byAdding: .hour,
                                              value: -24,
                                              to: Date()) ?? Date()

        let roundEarlyDate = Date(timeIntervalSince1970: ceil(earlyDate.timeIntervalSince1970 / 60.0) * 60.0)

        let ratesQueryPairs: [MarketPulse.Query.Rates.Pair] = assets.flatMap {
            [.init(amountAssetId: $0.id, priceAssetId: MarketPulse.usdAssetId),
             .init(amountAssetId: $0.id, priceAssetId: MarketPulse.eurAssetId)]
        }
        let ratesQuery = MarketPulse.Query.Rates(pair: ratesQueryPairs, timestamp: nil)

        let ratesQueryYesterdayPairs: [MarketPulse.Query.Rates.Pair] = assets.flatMap {
            [.init(amountAssetId: $0.id, priceAssetId: MarketPulse.usdAssetId),
             .init(amountAssetId: $0.id, priceAssetId: MarketPulse.eurAssetId)]
        }
        let ratesQueryYesterday = MarketPulse.Query.Rates(pair: ratesQueryYesterdayPairs, timestamp: roundEarlyDate)

        let assetsIdentifiers = assets.map { $0.id }
        let assetsQuery = assetsRepository.assets(by: assetsIdentifiers)

        return Observable.zip(pairsPriceRepository.ratePairs(ratesQueryYesterday),
                              pairsPriceRepository.ratePairs(ratesQuery),
                              assetsQuery)
            .flatMap { yesterdayRates, nowRates, assetsRemote -> Observable<[MarketPulse.DTO.Asset]> in

                let assetsRemoteMap = assetsRemote.reduce(into: [String: Asset]()) {
                    $0[$1.id] = $1
                }

                let yesterdayRatesMap = yesterdayRates.reduce(into: [String: [String: MarketPulse.DTO.Rate]]()) {
                    var map = $0[$1.priceAssetId] ?? [String: MarketPulse.DTO.Rate]()

                    map[$1.amountAssetId] = $1
                    $0[$1.priceAssetId] = map
                }

                let nowRatesMap = nowRates.reduce(into: [String: [String: MarketPulse.DTO.Rate]]()) {
                    var map = $0[$1.priceAssetId] ?? [String: MarketPulse.DTO.Rate]()

                    map[$1.amountAssetId] = $1
                    $0[$1.priceAssetId] = map
                }

                let newAssets = assets.map { asset -> MarketPulse.DTO.Asset in

                    var rates: [String: Double] = [:]
                    rates[MarketPulse.usdAssetId] = nowRatesMap[MarketPulse.usdAssetId]?[asset.id]?.rate ?? 0
                    rates[MarketPulse.eurAssetId] = nowRatesMap[MarketPulse.eurAssetId]?[asset.id]?.rate ?? 0

                    var firstPrice: [String: Double] = [:]
                    firstPrice[MarketPulse.usdAssetId] = yesterdayRatesMap[MarketPulse.usdAssetId]?[asset.id]?.rate ?? 0
                    firstPrice[MarketPulse.eurAssetId] = yesterdayRatesMap[MarketPulse.eurAssetId]?[asset.id]?.rate ?? 0

                    let icon = assetsRemoteMap[asset.id]?.iconLogo ?? asset.icon
                    let name = (assetsRemoteMap[asset.id]?.ticker ?? assetsRemoteMap[asset.id]?.displayName) ?? asset.name

                    return MarketPulse.DTO.Asset(id: asset.id,
                                                 name: name,
                                                 icon: icon,
                                                 rates: rates,
                                                 firstPrice: firstPrice,
                                                 lastPrice: rates,
                                                 amountAsset: asset.amountAsset)
                }

                return self
                    .dbRepository
                    .saveAsssets(assets: newAssets)
                    .flatMap { _ -> Observable<[MarketPulse.DTO.Asset]> in Observable.just(newAssets) }
            }
    }
}

private struct AuthorizationInteractorLocalizableImp: AuthorizationInteractorLocalizableProtocol {
    var fallbackTitle: String { "" }

    var cancelTitle: String { "" }

    var readFromkeychain: String { "" }

    var saveInkeychain: String { "" }
}
