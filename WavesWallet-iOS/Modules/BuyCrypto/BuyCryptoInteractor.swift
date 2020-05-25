//
//  BuyCryptoInteractor.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 13.05.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import AppTools
import DomainLayer
import RxCocoa
import RxSwift

final class BuyCryptoInteractor: BuyCryptoInteractable {
    private let presenter: BuyCryptoPresentable

    private let networker: Networker

    private let stateTransformTrait: StateTransformTrait<BuyCryptoState>

    private let apiResponse = ApiResponse()

    private let disposeBag = DisposeBag()

    init(presenter: BuyCryptoPresentable,
         authorizationService: AuthorizationUseCaseProtocol,
         environmentRepository: EnvironmentRepositoryProtocol,
         assetsUseCase: AssetsUseCaseProtocol,
         gatewayWavesRepository: GatewaysWavesRepository,
         adCashGRPCService: AdCashGRPCService) {
        self.presenter = presenter

        let _state = BehaviorRelay<BuyCryptoState>(value: .isLoading)
        stateTransformTrait = StateTransformTrait(_state: _state, disposeBag: disposeBag)

        networker = Networker(authorizationService: authorizationService,
                              environmentRepository: environmentRepository,
                              gatewaysWavesRepository: gatewayWavesRepository,
                              assetsUseCase: assetsUseCase,
                              adCashGRPCService: adCashGRPCService)
    }

    private func performInitialLoading() {
        networker.getAssets { [weak self] result in
            switch result {
            case let .success(assets): self?.apiResponse.$didLoadACashAssets.accept(assets)
            case let .failure(error): self?.apiResponse.$aCashAssetsLoadingError.accept(error)
            }
        }
    }
}

// MARK: - IOTransformer

extension BuyCryptoInteractor: IOTransformer {
    func transform(_ input: BuyCryptoViewOutput) -> BuyCryptoInteractorOutput {
        input.viewWillAppear
            .take(1)
            .subscribe(onNext: { [weak self] in self?.performInitialLoading() })
            .disposed(by: disposeBag)

        StateTransform.fromIsLoadingToACashAssetsLoaded(stateTransformTrait: stateTransformTrait,
                                                        didLoadACashAssets: apiResponse.didLoadACashAssets)

        StateTransform.fromIsLoadingToLoadingError(stateTransformTrait: stateTransformTrait,
                                                   aCashAssetsLoadingError: apiResponse.aCashAssetsLoadingError)

        StateTransform.fromLoadingErrorToIsLoading(stateTransformTrait: stateTransformTrait, didTapRetry: input.didTapRetry)

        // didSelectFiatItem и didSelectCryptoItem проходят транзитом через интерактор
        // в presenter необходимо изменять title(ы) на лейблах и кнопке
        return BuyCryptoInteractorOutput(readOnlyState: stateTransformTrait.readOnlyState,
                                         didSelectFiatItem: input.didSelectFiatItem,
                                         didSelectCryptoItem: input.didSelectCryptoItem)
    }
}

extension BuyCryptoInteractor {
    private enum StateTransform {
        static func fromIsLoadingToACashAssetsLoaded(stateTransformTrait: StateTransformTrait<BuyCryptoState>,
                                                     didLoadACashAssets: Observable<AssetsInfo>) {
            let fromIsLoadingToACashAssetsLoaded = didLoadACashAssets
                .filteredByState(stateTransformTrait.readOnlyState) { state -> Bool in
                    switch state {
                    case .isLoading: return true
                    default: return false
                    }
                }
                .map { BuyCryptoState.aCashAssetsLoaded($0) }

            fromIsLoadingToACashAssetsLoaded.bind(to: stateTransformTrait._state).disposed(by: stateTransformTrait.disposeBag)
        }

        static func fromIsLoadingToLoadingError(stateTransformTrait: StateTransformTrait<BuyCryptoState>,
                                                aCashAssetsLoadingError: Observable<Error>) {
            let fromIsLoadingToLoadingError = aCashAssetsLoadingError
                .filteredByState(stateTransformTrait.readOnlyState) { state -> Bool in
                    switch state {
                    case .isLoading: return true
                    default: return false
                    }
                }
                .map { BuyCryptoState.loadingError($0.localizedDescription) }

            fromIsLoadingToLoadingError.bind(to: stateTransformTrait._state).disposed(by: stateTransformTrait.disposeBag)
        }

        static func fromLoadingErrorToIsLoading(stateTransformTrait: StateTransformTrait<BuyCryptoState>,
                                                didTapRetry: ControlEvent<Void>) {
            let fromLoadingErrorToIsLoading = didTapRetry
                .filteredByState(stateTransformTrait.readOnlyState) { state -> Bool in
                    switch state {
                    case .loadingError: return true
                    default: return false
                    }
                }
                .map { BuyCryptoState.isLoading }

            fromLoadingErrorToIsLoading.bind(to: stateTransformTrait._state).disposed(by: stateTransformTrait.disposeBag)
        }
    }
}

// MARK: - NetWorker

import Moya

extension BuyCryptoInteractor {
    private final class Networker {
        private let authorizationService: AuthorizationUseCaseProtocol
        private let environmentRepository: EnvironmentRepositoryProtocol
        private let gatewaysWavesRepository: GatewaysWavesRepository
        private let assetsUseCase: AssetsUseCaseProtocol
        private let adCashGRPCService: AdCashGRPCService

        private let disposeBag = DisposeBag()

        init(authorizationService: AuthorizationUseCaseProtocol,
             environmentRepository: EnvironmentRepositoryProtocol,
             gatewaysWavesRepository: GatewaysWavesRepository,
             assetsUseCase: AssetsUseCaseProtocol,
             adCashGRPCService: AdCashGRPCService) {
            self.authorizationService = authorizationService
            self.environmentRepository = environmentRepository
            self.assetsUseCase = assetsUseCase
            self.gatewaysWavesRepository = gatewaysWavesRepository
            self.adCashGRPCService = adCashGRPCService
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

//        private func getAssets(walletAddress: String,
//                               ids: [String],
//                               fiatAssets: [FiatAsset],
//                               completion: @escaping (Result<AssetsInfo, Error>) -> Void) {
//            assetsUseCase.assets(by: ids, accountAddress: walletAddress)
//                .subscribe(onNext: { cryptoAssets in
//                    let assetsInfo = AssetsInfo(fiatAssets: fiatAssets, cryptoAssets: cryptoAssets)
//                    completion(.success(assetsInfo))
//                },
//                           onError: { error in
//                            let response = error as? MoyaError
//                            response?.response?.data
//                            completion(.failure(error))
//                })
//                .disposed(by: disposeBag)
//        }
    }
}
