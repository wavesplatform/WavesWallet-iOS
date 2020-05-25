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
    final class Networker {
        private let authorizationService: AuthorizationUseCaseProtocol
        private let environmentRepository: EnvironmentRepositoryProtocol
        private let gatewaysWavesRepository: GatewaysWavesRepository
        private let assetsUseCase: AssetsUseCaseProtocol
        private let adCashGRPCService: AdCashGRPCService
        private let developmentConfigRepository: DevelopmentConfigsRepositoryProtocol
        private let serverEnvironmentRepository: ServerEnvironmentRepository

        private let disposeBag = DisposeBag()

        init(authorizationService: AuthorizationUseCaseProtocol,
             environmentRepository: EnvironmentRepositoryProtocol,
             gatewaysWavesRepository: GatewaysWavesRepository,
             assetsUseCase: AssetsUseCaseProtocol,
             adCashGRPCService: AdCashGRPCService,
             developmentConfigRepository: DevelopmentConfigsRepositoryProtocol,
             serverEnvironmentRepository: ServerEnvironmentRepository) {
            self.authorizationService = authorizationService
            self.environmentRepository = environmentRepository
            self.assetsUseCase = assetsUseCase
            self.gatewaysWavesRepository = gatewaysWavesRepository
            self.adCashGRPCService = adCashGRPCService
            self.developmentConfigRepository = developmentConfigRepository
            self.serverEnvironmentRepository = serverEnvironmentRepository
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
        ///   - senderAsset: <#senderAsset description#>
        ///   - recipientAsset: <#recipientAsset description#>
        func getExchangeRate(senderAsset: String, recipientAsset: String, completion: @escaping (Result<Void, Error>) -> Void) {
//            Observable.zip(authorizationService.authorizedWallet(), developmentConfig.developmentConfigs())
//                .catchError { Observable.error($0) }
//                .subscribe(onNext: { signedWallet, devConfig in
//
//                },
//                           onError: { error in }).disposed(by: disposeBag)
////            adCashGRPCService.getACashAssetsExchangeRate(signedWallet: <#T##SignedWallet#>, senderAsset: <#T##String#>, recipientAsset: <#T##String#>, senderAssetAmount: <#T##Double#>, completion: <#T##(Result<Void, Error>) -> Void#>)
//
//
//            gatewaysWavesRepository.depositTransferBinding(serverEnvironment: <#T##ServerEnvironment#>, oAToken: <#T##WEOAuthTokenDTO#>, request: <#T##TransferBindingRequest#>)
        }
    }
}
