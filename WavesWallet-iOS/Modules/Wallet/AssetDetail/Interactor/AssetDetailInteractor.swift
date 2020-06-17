//
//  AssetViewInteractor.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 06.08.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import RxSwift
import WavesSDK

fileprivate enum Constants {
    static let transactionLimit: Int = 10
    // Current id is USD-N
    static let usdAssetId = "DG2xFkPdDwKUoBkzGAhQtLpSGzfXLiCYPEzeKH2Ad24p"
}

final class AssetDetailInteractor: AssetDetailInteractorProtocol {
    private let authorizationInteractor: AuthorizationUseCaseProtocol
    private let accountBalanceInteractor: AccountBalanceUseCaseProtocol
    private let transactionsInteractor: TransactionsUseCaseProtocol
    private let assetsBalanceSettings: AssetsBalanceSettingsUseCaseProtocol
    private let gatewaysWavesRepository: GatewaysWavesRepository
    private let weOAuthRepository: WEOAuthRepositoryProtocol
    private let pairsPriceRepository: DexPairsPriceRepositoryProtocol
    private let serverEnvironmentUseCase: ServerEnvironmentRepository
    
    private let refreshAssetsSubject: PublishSubject<[AssetDetailTypes.DTO.PriceAsset]> = PublishSubject()
    
    init(authorizationInteractor: AuthorizationUseCaseProtocol,
         accountBalanceInteractor: AccountBalanceUseCaseProtocol,
         transactionsInteractor: TransactionsUseCaseProtocol,
         assetsBalanceSettings: AssetsBalanceSettingsUseCaseProtocol,
         gatewaysWavesRepository: GatewaysWavesRepository,
         weOAuthRepository: WEOAuthRepositoryProtocol,
         pairsPriceRepository: DexPairsPriceRepositoryProtocol,
         serverEnvironmentUseCase: ServerEnvironmentRepository) {
        
        self.authorizationInteractor = authorizationInteractor
        self.accountBalanceInteractor = accountBalanceInteractor
        self.transactionsInteractor = transactionsInteractor
        self.assetsBalanceSettings = assetsBalanceSettings
        self.gatewaysWavesRepository = gatewaysWavesRepository
        self.weOAuthRepository = weOAuthRepository
        self.pairsPriceRepository = pairsPriceRepository
        self.serverEnvironmentUseCase = serverEnvironmentUseCase
    }
    
    private let disposeBag: DisposeBag = DisposeBag()

    func assets(by ids: [String]) -> Observable<[AssetDetailTypes.DTO.PriceAsset]> {
        return Observable.merge(refreshAssetsSubject.asObserver(),
                                assets(by: ids,
                                       isNeedUpdate: false))
    }

    private func assets(by ids: [String], isNeedUpdate _: Bool) -> Observable<[AssetDetailTypes.DTO.PriceAsset]> {
        return accountBalanceInteractor.balances()
            .take(1)
            .map {
                $0.filter { asset -> Bool in
                    ids.contains(asset.assetId)
                }
            }
            .map { $0.map { $0.mapToAsset() } }
            .flatMap { [weak self] (assets) -> Observable<[AssetDetailTypes.DTO.PriceAsset]> in
                guard let self = self else { return Observable.empty() }
                let pairs: [DomainLayer.DTO.Dex.SimplePair] = assets
                    .map { .init(amountAsset: $0.info.id, priceAsset: Constants.usdAssetId) }

                let earlyDate = Calendar.current.date(byAdding: .hour, value: -24, to: Date()) ?? Date()
                let roundEarlyDate = Date(timeIntervalSince1970: ceil(earlyDate.timeIntervalSince1970 / 60.0) * 60.0)

                let serverEnvironment = self.serverEnvironmentUseCase.serverEnvironment()

                let pairsRateNow = serverEnvironment
                    .flatMap { [weak self] serverEnvironment -> Observable<[DomainLayer.DTO.Dex.PairRate]> in
                        guard let self = self else { return Observable.empty() }
                        return self
                            .pairsPriceRepository
                            .pairsRate(serverEnvironment: serverEnvironment,
                                       query: .init(pairs: pairs,
                                                    timestamp: nil))
                    }

                let pairsRateYesterday = serverEnvironment
                    .flatMap { [weak self] serverEnvironment -> Observable<[DomainLayer.DTO.Dex.PairRate]> in
                        guard let self = self else { return Observable.empty() }
                        return self
                            .pairsPriceRepository
                            .pairsRate(serverEnvironment: serverEnvironment,
                                       query: .init(pairs: pairs,
                                                    timestamp: roundEarlyDate))
                    }

                let token = self.authorizationInteractor
                    .authorizedWallet()
                    .flatMap { [weak self] signedWallet -> Observable<WEOAuthTokenDTO> in
                        guard let self = self else { return Observable.never() }
                        return self.weOAuthRepository.oauthToken(signedWallet: signedWallet)
                    }

                let gatewaysAssetBinding = Observable.zip(serverEnvironment, token)
                    .flatMap { [weak self] (serverEnvironment, token) -> Observable<[GatewaysAssetBinding]> in

                        guard let self = self else { return Observable.never() }
                        
                        let request = AssetBindingsRequest(assetType: nil,
                                                           direction: .deposit,
                                                           includesExternalAssetTicker: nil,
                                                           includesWavesAsset: nil)

                        return self.gatewaysWavesRepository
                            .assetBindingsRequest(serverEnvironment: serverEnvironment,
                                                  oAToken: token, request: request)
                    }

                return Observable.zip(pairsRateNow, pairsRateYesterday, gatewaysAssetBinding)
                    .map { ratesNow, ratesYertarday, gatewaysAssetBinding -> [AssetDetailTypes.DTO.PriceAsset] in
                        
                        let ratesNowMap = ratesNow.reduce(into: [String: DomainLayer.DTO.Dex.PairRate].init()) {
                            $0[$1.amountAssetId] = $1
                        }

                        let ratesYerstardayMap = ratesYertarday
                            .reduce(into: [String: DomainLayer.DTO.Dex.PairRate].init()) {
                                $0[$1.amountAssetId] = $1
                            }

                        var priceAssets: [AssetDetailTypes.DTO.PriceAsset] = []

                        for asset in assets {
                            
                            let isNeedCard = gatewaysAssetBinding
                                .first { asset.info.id == $0.recipientAsset.asset } != nil
                            
                            let rateNow = ratesNowMap[asset.info.id]?.rate ?? 0
                            let rateYerstarday = ratesYerstardayMap[asset.info.id]?.rate ?? 0

                            let price = AssetDetailTypes.DTO.Price(firstPrice: rateYerstarday,
                                                                   lastPrice: rateNow,
                                                                   priceUSD: Money(value: Decimal(rateNow),
                                                                                   WavesSDKConstants.FiatDecimals))
                            priceAssets.append(.init(hasNeedCard: isNeedCard,
                                                     price: price,
                                                     asset: asset))
                        }
                        return priceAssets
                    }
            }
    }

    func transactions(by assetId: String) -> Observable<[SmartTransaction]> {
        return authorizationInteractor
            .authorizedWallet()
            .flatMap { [weak self] wallet -> Observable<[SmartTransaction]> in

                guard let self = self else { return Observable.never() }

                return self.transactionsInteractor.transactionsSync(by: wallet.address,
                                                                    specifications: .init(page: .init(offset: 0,
                                                                                                      limit: Constants
                                                                                                          .transactionLimit),
                                                                                          assets: [assetId],
                                                                                          senders: [],
                                                                                          types: TransactionType.all))
                    .flatMap { (txs) -> Observable<[SmartTransaction]> in
                        Observable.just(txs.resultIngoreError ?? [])
                    }
            }
    }

    func refreshAssets(by ids: [String]) {
        assets(by: ids, isNeedUpdate: true)
            .take(1)
            .subscribe(weak: self, onNext: { owner, assets in
                owner.refreshAssetsSubject.onNext(assets)
            })
            .disposed(by: disposeBag)
    }

    func toggleFavoriteFlagForAsset(by id: String, isFavorite: Bool) {
        return authorizationInteractor
            .authorizedWallet()
            .flatMap { [weak self] wallet -> Observable<Bool> in
                guard let self = self else { return Observable.never() }
                return self.assetsBalanceSettings.setFavorite(by: wallet.address, assetId: id, isFavorite: isFavorite)
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
}

private extension DomainLayer.DTO.SmartAssetBalance {
    func mapToAsset() -> AssetDetailTypes.DTO.Asset {
        return AssetDetailTypes.DTO.Asset(info: mapToInfo(),
                                          balance: mapToBalance())
    }

    func mapToBalance() -> AssetDetailTypes.DTO.Asset.Balance {
        let decimal = asset.precision

        let totalMoney = Money(totalBalance, decimal)
        let avaliableMoney = Money(availableBalance, decimal)
        let leasedMoney = Money(leasedBalance, decimal)
        let inOrderMoney = Money(inOrderBalance, decimal)

        return AssetDetailTypes.DTO.Asset.Balance(totalMoney: totalMoney,
                                                  avaliableMoney: avaliableMoney,
                                                  leasedMoney: leasedMoney,
                                                  inOrderMoney: inOrderMoney,
                                                  isFiat: asset.isFiat)
    }

    func mapToInfo() -> AssetDetailTypes.DTO.Asset.Info {
        let id = asset.id
        let issuer = asset.sender
        let name = asset.name
        let displayName = asset.displayName
        let description = asset.description
        let issueDate = asset.timestamp
        let isReusable = asset.isReusable
        let isMyWavesToken = asset.isMyWavesToken
        let isWavesToken = asset.isWavesToken
        let isWaves = asset.isWaves
        let isFavorite = settings.isFavorite
        let isFiat = asset.isFiat
        let isSpam = asset.isSpam
        let isGateway = asset.isGateway
        let sortLevel = settings.sortLevel
        let icon = asset.iconLogo

        return .init(id: id,
                     issuer: issuer,
                     name: name,
                     displayName: displayName,
                     description: description,
                     issueDate: issueDate,
                     isReusable: isReusable,
                     isMyWavesToken: isMyWavesToken,
                     isWavesToken: isWavesToken,
                     isWaves: isWaves,
                     isFavorite: isFavorite,
                     isFiat: isFiat,
                     isSpam: isSpam,
                     isGateway: isGateway,
                     sortLevel: sortLevel,
                     icon: icon,
                     assetBalance: self,
                     isStablecoin: asset.isStablecoin,
                     isQualified: asset.isQualified)
    }
}
