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
         gatewayWavesRepository: GatewaysWavesRepository,
         adCashGRPCService: AdCashGRPCService) {
        self.presenter = presenter

        let _state = BehaviorRelay<BuyCryptoState>(value: .isLoading)
        stateTransformTrait = StateTransformTrait(_state: _state, disposeBag: disposeBag)

        networker = Networker(authorizationService: authorizationService,
                              environmentRepository: environmentRepository,
                              gatewaysWavesRepository: gatewayWavesRepository,
                              adCashGRPCService: adCashGRPCService)
    }

    private func performInitialLoading() {
        networker.getAssets { [weak self] result in
            switch result {
            case .success(let assets): self?.apiResponse.$didLoadACashAssets.accept(assets)
            case .failure(let error): self?.apiResponse.$aCashAssetsLoadingError.accept(error)
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
                                                     didLoadACashAssets: Observable<[BuyCryptoInteractor.Asset]>) {
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

extension BuyCryptoInteractor {
    struct Asset {
        public let name: String
        public let id: String
        public let isCrypto: Bool
        public let decimals: Int32
        
        public let assetInfo: WalletEnvironment.AssetInfo
    }
    
    private final class Networker {
        private let authorizationService: AuthorizationUseCaseProtocol
        private let environmentRepository: EnvironmentRepositoryProtocol
        private let gatewaysWavesRepository: GatewaysWavesRepository
        private let adCashGRPCService: AdCashGRPCService

        private let disposeBag = DisposeBag()

        init(authorizationService: AuthorizationUseCaseProtocol,
             environmentRepository: EnvironmentRepositoryProtocol,
             gatewaysWavesRepository: GatewaysWavesRepository,
             adCashGRPCService: AdCashGRPCService) {
            self.authorizationService = authorizationService
            self.environmentRepository = environmentRepository
            self.gatewaysWavesRepository = gatewaysWavesRepository
            self.adCashGRPCService = adCashGRPCService
        }

        func getAssets(completion: @escaping (Result<[BuyCryptoInteractor.Asset], Error>) -> Void) {
            Observable.zip(authorizationService.authorizedWallet(), environmentRepository.walletEnvironment())
                .subscribe(onNext: { [weak self] in
                    self?.getACashAssets(signedWallet: $0, walletEnvironment: $1, completion: completion)
                },
                           onError: { error in completion(.failure(error)) })
                .disposed(by: disposeBag)
        }
        
        private func getACashAssets(signedWallet: SignedWallet,
                                    walletEnvironment: WalletEnvironment,
                                    completion: @escaping (Result<[BuyCryptoInteractor.Asset], Error>) -> Void) {
            let completionAdapter: (Result<[ACashAsset], Error>) -> Void = { result in
                switch result {
                case .success(let assets):
                    let newAssets = assets.compactMap { asset -> BuyCryptoInteractor.Asset? in
                        if let assetInfo = walletEnvironment.assets?.first(where: { $0.wavesId == asset.id }) {
                            return .init(name: asset.name,
                                         id: asset.id,
                                         isCrypto: asset.kind == .crypto,
                                         decimals: asset.decimals,
                                         assetInfo: assetInfo)
                        } else {
                            return nil
                        }
                    }
                    
                    completion(.success(newAssets))
                case .failure(let error):
                    completion(.failure(error))
                }
                
            }
            
            adCashGRPCService.getACashAssets(signedWallet: signedWallet, completion: completionAdapter)
        }
    }
}
