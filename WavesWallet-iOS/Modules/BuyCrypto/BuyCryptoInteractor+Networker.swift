//
//  BuyCryptoInteractor+Networker.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 25.05.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import DomainLayer
import RxSwift

// MARK: - NetWorker

extension BuyCryptoInteractor {
    struct ExchangeInfo {
        /// Выбранная валюта реального мира
        let senderAsset: FiatAsset

        /// Выбранная криптовалюта
        let recipientAsset: CryptoAsset

        /// Адрес для обмена выбранного крипто ассета (приходит из GatewayTransferBinding)
        let exchangeAddress: String

        /// Минимальный порог обмена для фиатной валюты
        let minLimit: Decimal

        /// Максимальный порог обмена для фиатной валюты
        let maxLimit: Decimal

        ///
        let rate: Double
    }

    final class Networker {
        private let authorizationService: AuthorizationUseCaseProtocol
        private let environmentRepository: EnvironmentRepositoryProtocol
        private let gatewaysWavesRepository: GatewaysWavesRepository
        private let assetsUseCase: AssetsUseCaseProtocol
        private let adCashGRPCService: AdCashGRPCService
        private let developmentConfigRepository: DevelopmentConfigsRepositoryProtocol
        private let serverEnvironmentRepository: ServerEnvironmentRepository
        private let weOAuthRepository: WEOAuthRepositoryProtocol

        private var exchangeRateDisposables: Disposable?
        private let disposeBag = DisposeBag()

        init(authorizationService: AuthorizationUseCaseProtocol,
             environmentRepository: EnvironmentRepositoryProtocol,
             gatewaysWavesRepository: GatewaysWavesRepository,
             assetsUseCase: AssetsUseCaseProtocol,
             adCashGRPCService: AdCashGRPCService,
             developmentConfigRepository: DevelopmentConfigsRepositoryProtocol,
             serverEnvironmentRepository: ServerEnvironmentRepository,
             weOAuthRepository: WEOAuthRepositoryProtocol) {
            self.authorizationService = authorizationService
            self.environmentRepository = environmentRepository
            self.assetsUseCase = assetsUseCase
            self.gatewaysWavesRepository = gatewaysWavesRepository
            self.adCashGRPCService = adCashGRPCService
            self.developmentConfigRepository = developmentConfigRepository
            self.serverEnvironmentRepository = serverEnvironmentRepository
            self.weOAuthRepository = weOAuthRepository
        }

        func getAssets(completion: @escaping (Result<BuyCryptoInteractor.AssetsInfo, Error>) -> Void) {
            Observable
                .zip(obtainRequestRequiredInfo(), environmentRepository.walletEnvironment())
                .flatMap { [weak self] requestRequiredInfo, walletEnvironment
                    -> Observable<(SignedWallet, WalletEnvironment, ServerEnvironment, DevelopmentConfigs, WEOAuthTokenDTO)> in
                    let (signedWallet, serverEnvironment, devConfig, _) = requestRequiredInfo
                    guard let sself = self else { return Observable.never() }

                    return sself.weOAuthRepository.oauthToken(signedWallet: signedWallet)
                        .map { (signedWallet, walletEnvironment, serverEnvironment, devConfig, $0) }
                }
                .flatMap { [weak self] signedWallet, walletEnvironment, serverEnvironment, devConfig, token
                    -> Observable<(SignedWallet, WalletEnvironment, DevelopmentConfigs, [GatewaysAssetBinding])> in

                    guard let sself = self else { return Observable.never() }

                    let request = AssetBindingsRequest(assetType: nil,
                                                       direction: .deposit,
                                                       includesExternalAssetTicker: nil,
                                                       includesWavesAsset: nil)
                    return sself.gatewaysWavesRepository.assetBindingsRequest(serverEnvironment: serverEnvironment,
                                                                              oAToken: token,
                                                                              request: request)
                        .map { (signedWallet, walletEnvironment, devConfig, $0) }
                }
                .subscribe(onNext: { [weak self] signedWallet, walletEnvironment, devConfig, gatewayAssetBindings in
                    self?.getACashAssets(signedWallet: signedWallet,
                                         walletEnvironment: walletEnvironment,
                                         devConfig: devConfig,
                                         gatewayAssetBindings: gatewayAssetBindings,
                                         completion: completion)
                },
                           onError: { error in completion(.failure(error)) })
                .disposed(by: disposeBag)
        }

        private func getACashAssets(signedWallet: SignedWallet,
                                    walletEnvironment: WalletEnvironment,
                                    devConfig: DevelopmentConfigs,
                                    gatewayAssetBindings: [GatewaysAssetBinding],
                                    completion: @escaping (Result<AssetsInfo, Error>) -> Void) {
            let completionAdapter: (Result<[ACashAsset], Error>) -> Void = { result in
                switch result {
                case let .success(assets):
                    let allAssets = walletEnvironment.generalAssets + (walletEnvironment.assets ?? [])

                    let fiatAssets = assets
                        .filter { $0.kind == .fiat }
                        .compactMap { asset -> FiatAsset? in
                            let assetInfo = allAssets.first(where: { $0.assetId == asset.id })
                            return .init(name: asset.name,
                                         id: asset.id,
                                         decimals: asset.decimals,
                                         assetInfo: assetInfo)
                        }

                    let cryptoAssets = assets
                        .filter { $0.kind == .crypto }
                        .compactMap { asset -> CryptoAsset? in
                            
                             // это необходимо для фильтрации
                            let id = asset.id.replacingOccurrences(of: "AC_USD", with: "USD")
                                .replacingOccurrences(of: "AC_WAVES", with: "WAVES")
                                .replacingOccurrences(of: "AC_WEST", with: "WEST")
                            
                            if devConfig.avaliableGatewayCryptoCurrency.contains(id) {
                                let assetBinding = gatewayAssetBindings.first(where: { $0.senderAsset.asset == asset.id })
                                let assetInfo = allAssets.first(where: { $0.assetId == assetBinding?.recipientAsset.asset })
                                return .init(name: asset.name,
                                             id: asset.id,
                                             decimals: asset.decimals,
                                             assetInfo: assetInfo)
                            } else {
                                return nil
                            }
                        }

                    let assetsInfo = AssetsInfo(fiatAssets: fiatAssets, cryptoAssets: cryptoAssets)
                    completion(.success(assetsInfo))

                case let .failure(error):
                    completion(.failure(error))
                }
            }

            adCashGRPCService.getACashAssets(signedWallet: signedWallet, completion: completionAdapter)
        }

        ///
        /// - Parameters:
        ///   - senderAsset: fiat item
        ///   - recipientAsset: crypto item
        ///   - amount: fiat amount entered user
        func getExchangeRate(senderAsset: FiatAsset,
                             recipientAsset: CryptoAsset,
                             amount: Double,
                             paymentSystem: PaymentMethod,
                             completion: @escaping (Result<ExchangeInfo, Error>) -> Void) {
            if exchangeRateDisposables != nil {
                exchangeRateDisposables?.dispose()
            }

            exchangeRateDisposables = obtainRequestRequiredInfo()
                .flatMap { [weak self] wallet, environments, devConfig, token
                    -> Observable<(SignedWallet, GatewaysTransferBinding, DevelopmentConfigs)> in
                    guard let sself = self else { return Observable.never() }
                    let request = TransferBindingRequest(asset: recipientAsset.id, recipientAddress: wallet.wallet.address)

                    return sself.gatewaysWavesRepository
                        .depositTransferBinding(serverEnvironment: environments, oAToken: token, request: request)
                        .map { gatewayTransferBinding -> (SignedWallet, GatewaysTransferBinding, DevelopmentConfigs) in
                            (wallet, gatewayTransferBinding, devConfig)
                        }
                }
                .catchError { Observable.error($0) }
                .subscribe(onNext: { [weak self] signedWallet, gatewayTransferBinding, devConfig in
                    let devConfigRate = devConfig
                        .gatewayMinFee[recipientAsset.assetInfo?.assetId ?? ""]?[senderAsset.id.lowercased()]

                    if recipientAsset.id.lowercased() == "ac_waves" || recipientAsset.id.lowercased() == "ac_west" {
                        self?.getSpecificExchangeRatesLimits(signedWallet: signedWallet,
                                                             gatewayTransferBinding: gatewayTransferBinding,
                                                             devConfigRate: devConfigRate,
                                                             senderAsset: senderAsset,
                                                             recipientAsset: recipientAsset,
                                                             paymentSystem: paymentSystem,
                                                             amount: amount,
                                                             completion: completion)
                    } else {
                        let completionAdapter: (Result<(min: Decimal, max: Decimal), Error>) -> Void = { result in
                            switch result {
                            case let .success((min, max)):
                                self?.getExchangeRates(signedWallet: signedWallet,
                                                       gatewayTransferBinding: gatewayTransferBinding,
                                                       senderAsset: senderAsset,
                                                       recipientAsset: recipientAsset,
                                                       minLimit: min,
                                                       maxLimit: max,
                                                       amount: amount,
                                                       paymentSystem: paymentSystem,
                                                       completion: completion)
                            case let .failure(error):
                                completion(.failure(error))
                            }
                        }

                        self?.getExchangeLimits(signedWallet: signedWallet,
                                                gatewayTransferBinding: gatewayTransferBinding,
                                                devConfigRate: devConfigRate,
                                                senderAsset: senderAsset,
                                                recipientAsset: recipientAsset,
                                                paymentSystem: paymentSystem,
                                                completion: completionAdapter)
                    }
                },
                           onError: { error in completion(.failure(error)) })
        }

        private func getExchangeRates(signedWallet: SignedWallet,
                                      gatewayTransferBinding: GatewaysTransferBinding,
                                      senderAsset: FiatAsset,
                                      recipientAsset: CryptoAsset,
                                      minLimit: Decimal,
                                      maxLimit: Decimal,
                                      amount: Double,
                                      paymentSystem: PaymentMethod,
                                      completion: @escaping (Result<ExchangeInfo, Error>) -> Void) {
            let completionAdapter: (Result<Double, Error>) -> Void = { result in
                switch result {
                case let .success(exchangeRate):
                    let rateInfo = ExchangeInfo(senderAsset: senderAsset,
                                                recipientAsset: recipientAsset,
                                                exchangeAddress: gatewayTransferBinding.addresses.first ?? "",
                                                minLimit: minLimit,
                                                maxLimit: maxLimit,
                                                rate: exchangeRate)

                    completion(.success(rateInfo))
                case let .failure(error):
                    completion(.failure(error))
                }
            }

            let senderAssetAmount: Double
            if Decimal(amount) < minLimit {
                let minLimitAsNSNumber = minLimit as NSNumber
                senderAssetAmount = Double(truncating: minLimitAsNSNumber)
            } else if Decimal(amount) > maxLimit {
                let maxLimitAsNSNumber = maxLimit as NSNumber
                senderAssetAmount = Double(truncating: maxLimitAsNSNumber)
            } else {
                senderAssetAmount = amount
            }

            // сколько получит пользователь для отображения в ibuy
            adCashGRPCService.getACashAssetsExchangeRate(signedWallet: signedWallet,
                                                         paymentSystem: paymentSystem,
                                                         senderAsset: senderAsset.id,
                                                         recipientAsset: recipientAsset.id,
                                                         senderAssetAmount: senderAssetAmount,
                                                         completion: completionAdapter)
        }

        private func getExchangeLimits(signedWallet: SignedWallet,
                                       gatewayTransferBinding: GatewaysTransferBinding,
                                       devConfigRate: DevelopmentConfigs.Rate?,
                                       senderAsset: FiatAsset,
                                       recipientAsset: CryptoAsset,
                                       paymentSystem: PaymentMethod,
                                       completion: @escaping (Result<(min: Decimal, max: Decimal), Error>) -> Void) {
            let completionAdapter: (Result<Double, Error>) -> Void = { result in
                switch result {
                case let .success(limitRate):
                    let decimalLimitRate = Decimal(limitRate)
                    var min: Decimal
                    let max: Decimal

                    if recipientAsset.id.lowercased() == "btc" {
                        min = 100 / Decimal(limitRate)
                        max = 9500 / Decimal(limitRate)
                    } else {
                        // coef необходим чтоб получить правильный минимум и максимум (они приходят в копейках)
                        let coef = Decimal(pow(10, Double(senderAsset.decimals)))

                        min = (gatewayTransferBinding.assetBinding.senderAmountMin / coef) / decimalLimitRate
                        max = (gatewayTransferBinding.assetBinding.senderAmountMax / coef) / decimalLimitRate
                    }

                    if let devConfigRate = devConfigRate {
                        let devRate = Decimal(devConfigRate.rate)
                        let devFlat = Decimal(devConfigRate.flat)

                        min = min * devRate + devFlat
                    }
                    completion(.success((min, max)))
                case let .failure(error):
                    completion(.failure(error))
                }
            }

            // чтобы получить лимиты в usd
            adCashGRPCService.getACashAssetsExchangeRate(signedWallet: signedWallet,
                                                         paymentSystem: paymentSystem,
                                                         senderAsset: senderAsset.id,
                                                         recipientAsset: "USD",
                                                         senderAssetAmount: 1,
                                                         completion: completionAdapter)
        }

        private func getSpecificExchangeRatesLimits(signedWallet: SignedWallet,
                                                    gatewayTransferBinding: GatewaysTransferBinding,
                                                    devConfigRate: DevelopmentConfigs.Rate?,
                                                    senderAsset: FiatAsset,
                                                    recipientAsset: CryptoAsset,
                                                    paymentSystem: PaymentMethod,
                                                    amount: Double,
                                                    completion: @escaping (Result<ExchangeInfo, Error>) -> Void) {
            let senderAmountMin = Double(truncating: gatewayTransferBinding.assetBinding.senderAmountMin as NSNumber)
            let senderAmountMax = Double(truncating: gatewayTransferBinding.assetBinding.senderAmountMax as NSNumber)

            var rateForMin: Double?
            var rateForMax: Double?

            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            adCashGRPCService.getACashAssetsExchangeRate(
                signedWallet: signedWallet,
                paymentSystem: paymentSystem,
                senderAsset: recipientAsset.id,
                recipientAsset: senderAsset.id,
                senderAssetAmount: senderAmountMin) { result in
                switch result {
                case let .success(rate):
                    rateForMin = rate
                case .failure:
                    rateForMin = 1
                    // не знаю как поступать в этой ситуации
                }
                dispatchGroup.leave()
            }

            dispatchGroup.enter()
            adCashGRPCService.getACashAssetsExchangeRate(
                signedWallet: signedWallet,
                paymentSystem: paymentSystem,
                senderAsset: recipientAsset.id,
                recipientAsset: senderAsset.id,
                senderAssetAmount: senderAmountMax) { result in
                switch result {
                case let .success(rate):
                    rateForMax = rate
                case .failure:
                    rateForMax = 1
                    // не знаю как поступать в этой ситуации
                }
                dispatchGroup.leave()
            }

            dispatchGroup.notify(queue: DispatchQueue.global(), execute: { [weak self] in
                let decimals = Double(recipientAsset.decimals)
                let coef = pow(10, decimals)

                let devRate = devConfigRate?.rate ?? 1
                let devFlat = Double(devConfigRate?.flat ?? 0)

                var minLimit = (senderAmountMin / coef) * (rateForMin ?? 1)
                minLimit *= devRate
                minLimit += devFlat

                let maxLimit = ((senderAmountMax / coef) * (rateForMax ?? 1))

                self?.getExchangeRates(signedWallet: signedWallet,
                                       gatewayTransferBinding: gatewayTransferBinding,
                                       senderAsset: senderAsset,
                                       recipientAsset: recipientAsset,
                                       minLimit: Decimal(minLimit),
                                       maxLimit: Decimal(maxLimit),
                                       amount: amount,
                                       paymentSystem: paymentSystem,
                                       completion: completion)
            })
        }

        func deposite(senderAsset: FiatAsset,
                      recipientAsset: CryptoAsset,
                      exchangeAddress: String,
                      amount: Double,
                      paymentSystem: PaymentMethod,
                      completion: @escaping (Result<URL, Error>) -> Void) {
            authorizationService.authorizedWallet()
                .subscribe(onNext: { [weak self] signedWallet in
                    let completionAdapter: (Result<String, Error>) -> Void = { result in
                        switch result {
                        case let .success(queryParams):
                            let urlString = DomainLayerConstants.URL.advcash + queryParams
                            if let url = URL(string: urlString) {
                                completion(.success(url))
                            } else {
//                                completion(.failure(<#T##Error#>))
                            }
                        case let .failure(error):
                            completion(.failure(error))
                        }
                    }
                    
                    self?.adCashGRPCService.deposite(signedWallet: signedWallet,
                                                     paymentSystem: paymentSystem,
                                                     senderAsset: senderAsset.id,
                                                     recipientAsset: recipientAsset.id,
                                                     exchangeAddress: exchangeAddress,
                                                     amount: amount,
                                                     completion: completionAdapter)
                },
                           onError: { error in completion(.failure(error)) })
                .disposed(by: disposeBag)
        }

        private func obtainRequestRequiredInfo()
            -> Observable<(SignedWallet, ServerEnvironment, DevelopmentConfigs, WEOAuthTokenDTO)> {
            Observable
                .zip(authorizationService.authorizedWallet(),
                     developmentConfigRepository.developmentConfigs(),
                     serverEnvironmentRepository.serverEnvironment())
                .flatMap { [weak self] signedWallet, devConfig, serverEnvironment
                    -> Observable<(SignedWallet, ServerEnvironment, DevelopmentConfigs, WEOAuthTokenDTO)> in
                    guard let sself = self else { return Observable.never() }

                    return sself.weOAuthRepository.oauthToken(signedWallet: signedWallet)
                        .map { (signedWallet, serverEnvironment, devConfig, $0) }
                }
        }
    }
}
