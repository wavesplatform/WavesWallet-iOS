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
        let minLimit: Decimal
        let maxLimit: Decimal
        
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
            Observable.zip(authorizationService.authorizedWallet(), environmentRepository.walletEnvironment())
                .subscribe(onNext: { [weak self] signedWallet, walletEnvironment in
                    self?.getACashAssets(signedWallet: signedWallet, walletEnvironment: walletEnvironment, completion: completion)
                },
                           onError: { error in completion(.failure(error)) })
                .disposed(by: disposeBag)
        }

        private func getACashAssets(signedWallet: SignedWallet,
                                    walletEnvironment: WalletEnvironment,
                                    completion: @escaping (Result<AssetsInfo, Error>) -> Void) {
            let completionAdapter: (Result<[ACashAsset], Error>) -> Void = { result in
                switch result {
                case let .success(assets):
                    let walletEnvironmentAssets = walletEnvironment.generalAssets + (walletEnvironment.assets ?? [])

                    let fiatAssets = assets.filter { $0.kind == .fiat }
                        .compactMap { asset -> FiatAsset? in
                            if let assetInfo = walletEnvironmentAssets.first(where: { $0.wavesId == asset.id }) {
                                return .init(name: asset.name,
                                             id: asset.id,
                                             decimals: asset.decimals,
                                             assetInfo: assetInfo)
                            } else {
                                return nil
                            }
                        }

                    let cryptoAssets = assets.filter { $0.kind == .crypto }
                        .compactMap { asset -> CryptoAsset? in
                            if let assetInfo = walletEnvironmentAssets.first(where: { $0.gatewayId == asset.id }) {
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
        
        /// <#Description#>
        /// - Parameters:
        ///   - senderAsset: fiat item
        ///   - recipientAsset: crypto item
        func getExchangeRate(senderAsset: String,
                             recipientAsset: String,
                             completion: @escaping (Result<ExchangeInfo, Error>) -> Void) {
            Observable.zip(authorizationService.authorizedWallet(),
                           developmentConfigRepository.developmentConfigs(),
                           serverEnvironmentRepository.serverEnvironment())
                .flatMap { [weak self] signedWallet, devConfig, serverEnvironment
                    -> Observable<(SignedWallet, ServerEnvironment, DevelopmentConfigs, WEOAuthTokenDTO)> in
                    guard let sself = self else { return Observable.never() }
                    
                    return sself.weOAuthRepository.oauthToken(signedWallet: signedWallet)
                        .map { (signedWallet, serverEnvironment, devConfig, $0) }
                }
                .flatMap { [weak self] signedWallet, serverEnvironment, devConfig, token
                    -> Observable<(SignedWallet, GatewaysTransferBinding)> in
                    guard let sself = self else { return Observable.never() }
                    let transferBindingRequest = TransferBindingRequest(asset: recipientAsset,
                                                                        recipientAddress: signedWallet.wallet.address)
                    
                    return sself.gatewaysWavesRepository.depositTransferBinding(serverEnvironment: serverEnvironment,
                                                                                oAToken: token,
                                                                                request: transferBindingRequest)
                        .map { gatewayTransferBinding -> (SignedWallet, GatewaysTransferBinding) in
                            (signedWallet, gatewayTransferBinding)
                        }
                }
                .catchError { Observable.error($0) }
                .subscribe(onNext: { [weak self] signedWallet, gatewayTransferBinding in
                    // чтобы получить лимиты для usnd
                    self?.adCashGRPCService.getACashAssetsExchangeRate(
                        signedWallet: signedWallet,
                        senderAsset: senderAsset,
                        recipientAsset: "USD",
                        senderAssetAmount: 1) { result in
                            switch result {
                            case .success(let rate):
                                let rateInfo: ExchangeInfo
                                if recipientAsset != "USDN" {
                                    let min: Decimal = 100
                                    let max: Decimal = 1000
                                    
                                    rateInfo = ExchangeInfo(minLimit: min, maxLimit: max, rate: rate)
                                } else {
                                    let min: Decimal = Decimal(rate) * gatewayTransferBinding.assetBinding.senderAmountMin
                                    let max: Decimal = Decimal(rate) * gatewayTransferBinding.assetBinding.senderAmountMax
                                    
                                    rateInfo = ExchangeInfo(minLimit: min, maxLimit: max, rate: rate)
                                }
                                
                                completion(.success(rateInfo))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                    }
                    
                },
                           onError: { error in })
                .disposed(by: disposeBag)
        }
        
//        private func getExchangeRates(signedWallet: SignedWallet, senderAsset: String, recipientAsset: String) {
//            let dispatchGroup = DispatchGroup()
//
//            var usdnRateResult: Result<Double, Error>
//            dispatchGroup.enter()
//
//
//            var iBuyRateResult: Result<Double, Error>
//            dispatchGroup.enter()
//            // сколько получит пользователь для отображения в ibuy
////            adCashGRPCService.getACashAssetsExchangeRate(
////                signedWallet: signedWallet,
////                senderAsset: senderAsset,
////                recipientAsset: recipientAsset,
////                senderAssetAmount: 1) { result in
////                    iBuyRateResult = result
////                    switch result {
////                    case .success(let rate): break
////                    case .failure(let error): break
////                    }
////                    dispatchGroup.leave()
////            }
//
////            dispatchGroup.notify(queue: .global()) {
////
////            }
//        }
//
//        func getUserCryptoExchange() {
//
//        }
    }
}
