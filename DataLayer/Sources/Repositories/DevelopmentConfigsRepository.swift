//
//  ServerMaintenanceRepository.swift
//  DataLayer
//
//  Created by rprokofev on 19.11.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import DomainLayer
import Foundation
import Moya
import RxSwift

private struct DevelopmentConfigsDTO: Decodable {
    let serviceAvailable: Bool
    let matcherSwapTimestamp: Date
    let matcherSwapAddress: String
    let exchangeClientSecret: String
    let staking: [Staking]
    let lockedPairs: [String]
    //  First key is assetId and second key is fiat
    //  For example: value["DG2xFkPdDwKUoBkzGAhQtLpSGzfXLiCYPEzeKH2Ad24p"]["usn"]
    let gatewayMinFee: [String: [String: Rate]]
    let gatewayMinLimit: [String: Limit]
    let avaliableGatewayCryptoCurrency: [String]
    let marketPairs: [String]
    let enableCreateSmartContractPairOrder: Bool?

    enum CodingKeys: String, CodingKey {
        case serviceAvailable = "service_available"
        case matcherSwapTimestamp = "matcher_swap_timestamp"
        case matcherSwapAddress = "matcher_swap_address"
        case exchangeClientSecret = "exchange_client_secret"
        case gatewayMinLimit = "gateway_min_limit"
        case avaliableGatewayCryptoCurrency = "avaliable_gateway_crypto_currency"
        case lockedPairs = "locked_pairs"
        case gatewayMinFee = "gateway_min_fee"
        case marketPairs = "DEX.MARKET_PAIRS"
        case staking
        case enableCreateSmartContractPairOrder
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        serviceAvailable = try container.decode(Bool.self, forKey: .serviceAvailable)
        matcherSwapTimestamp = try container.decode(Date.self, forKey: .matcherSwapTimestamp)
        matcherSwapAddress = try container.decode(String.self, forKey: .matcherSwapAddress)
        exchangeClientSecret = try container.decode(String.self, forKey: .exchangeClientSecret)
        staking = try container.decode([Staking].self, forKey: .staking)
        lockedPairs = try container.decodeIfPresent([String].self, forKey: .lockedPairs) ?? []
        gatewayMinFee = try container.decode([String: [String: Rate]].self, forKey: .gatewayMinFee)
        marketPairs = try container.decodeIfPresent([String].self, forKey: .marketPairs) ?? []
        gatewayMinLimit = try container.decode([String: Limit].self, forKey: .gatewayMinLimit)
        avaliableGatewayCryptoCurrency = try container
            .decodeIfPresent([String].self, forKey: .avaliableGatewayCryptoCurrency) ?? []

        enableCreateSmartContractPairOrder = try container.decode(Bool?.self, forKey: .enableCreateSmartContractPairOrder)
    }
}

private struct Rate: Decodable {
    let rate: Double
    let flat: Int64
}

private struct Limit: Decodable {
    let min: Int64
    let max: Int64
}

private struct Staking: Decodable {
    let type: String
    let neutrinoAssetId: String
    let addressByPayoutsAnnualPercent: String
    let addressStakingContract: String
    let addressByCalculateProfit: String
    let addressesByPayoutsAnnualPercent: [String]
    let referralShare: Int64

    enum CodingKeys: String, CodingKey {
        case type
        case neutrinoAssetId = "neutrino_asset_id"
        case addressByPayoutsAnnualPercent = "address_by_payouts_annual_percent"
        case addressStakingContract = "address_staking_contract"
        case addressByCalculateProfit = "address_by_calculate_profit"
        case addressesByPayoutsAnnualPercent = "addresses_by_payouts_annual_percent"
        case referralShare
    }
}

public final class DevelopmentConfigsRepository: DevelopmentConfigsRepositoryProtocol {
    private let environmentRepository: EnvironmentRepositoryProtocol

    private let environmentAPIService: MoyaProvider<ResourceAPI.Service.Environment> = .anyMoyaProvider()

    private lazy var developmentConfigsShare: Observable<DevelopmentConfigs> = downloadDevelopmentConfigs().share(replay: 1,
                                                                                                                  scope: SubjectLifetimeScope
                                                                                                                      .forever)

    private let developmentConfigsLocal: BehaviorSubject<DevelopmentConfigs?> = BehaviorSubject(value: nil)

    init(environmentRepository: EnvironmentRepositoryProtocol) {
        self.environmentRepository = environmentRepository
    }

    public func isEnabledMaintenance() -> Observable<Bool> {
        return developmentConfigs()
            .flatMap { Observable.just($0.serviceAvailable == false) }
            .catchError { _ in Observable.just(false) }
    }

    public func developmentConfigs() -> Observable<DevelopmentConfigs> {
        if let value = try? developmentConfigsLocal.value() {
            return Observable.just(value)
        }

        return developmentConfigsShare.do(onNext: { [weak self] developmentConfigs in
            self?.developmentConfigsLocal.onNext(developmentConfigs)
        })
    }

    private func downloadDevelopmentConfigs() -> Observable<DevelopmentConfigs> {
        return environmentAPIService.rx.request(.get(kind: environmentRepository.environmentKind,
                                                     isTest: ApplicationDebugSettings.isEnableEnviromentTest))
            .map(DevelopmentConfigsDTO.self,
                 atKeyPath: nil,
                 using: JSONDecoder.decoderByDateWithSecond(0),
                 failsOnEmptyData: false)
            .asObservable()
            .map { config -> DevelopmentConfigs in
                let staking = config.staking.map {
                    DevelopmentConfigs.Staking(type: $0.type,
                                               neutrinoAssetId: $0.neutrinoAssetId,
                                               addressByPayoutsAnnualPercent: $0.addressByPayoutsAnnualPercent,
                                               addressStakingContract: $0.addressStakingContract,
                                               addressByCalculateProfit: $0.addressByCalculateProfit,
                                               addressesByPayoutsAnnualPercent: $0.addressesByPayoutsAnnualPercent,
                                               referralShare: $0.referralShare)
                }

                let gatewayMinFee = config.gatewayMinFee.mapValues { value -> [String: DevelopmentConfigs.Rate] in
                    value.mapValues { value -> DevelopmentConfigs.Rate in
                        DevelopmentConfigs.Rate(rate: value.rate, flat: value.flat)
                    }
                }

                let marketPairs = config.marketPairs.compactMap { pair -> DevelopmentConfigs.MarketPair? in
                    let splitedPair = pair.split(separator: "/")
                    if splitedPair.isEmpty || splitedPair.count < 2 {
                        return nil
                    } else {
                        return DevelopmentConfigs.MarketPair(amount: String(splitedPair[0]),
                                                             price: String(splitedPair[1]))
                    }
                }

                let gatewayMinLimit = config.gatewayMinLimit.mapValues { DevelopmentConfigs.Limit(min: $0.min, max: $0.max) }

                return DevelopmentConfigs(serviceAvailable: config.serviceAvailable,
                                          matcherSwapTimestamp: config.matcherSwapTimestamp,
                                          matcherSwapAddress: config.matcherSwapAddress,
                                          exchangeClientSecret: config.exchangeClientSecret,
                                          staking: staking,
                                          lockedPairs: config.lockedPairs,
                                          gatewayMinFee: gatewayMinFee,
                                          marketPairs: marketPairs,
                                          gatewayMinLimit: gatewayMinLimit,
                                          avaliableGatewayCryptoCurrency: config.avaliableGatewayCryptoCurrency,
                                          enableCreateSmartContractPairOrder: config.enableCreateSmartContractPairOrder ?? true)
            }
    }
}
