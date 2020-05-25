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
         adCashGRPCService: AdCashGRPCService,
         developmentConfigRepository: DevelopmentConfigsRepositoryProtocol,
         serverEnvironmentRepository: ServerEnvironmentRepository) {
        self.presenter = presenter

        let _state = BehaviorRelay<BuyCryptoState>(value: .isLoading)
        stateTransformTrait = StateTransformTrait(_state: _state, disposeBag: disposeBag)

        networker = Networker(authorizationService: authorizationService,
                              environmentRepository: environmentRepository,
                              gatewaysWavesRepository: gatewayWavesRepository,
                              assetsUseCase: assetsUseCase,
                              adCashGRPCService: adCashGRPCService,
                              developmentConfigRepository: developmentConfigRepository,
                              serverEnvironmentRepository: serverEnvironmentRepository)
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

        static func fromACashAssetsLoadedToCheckingExchangePair(stateTransformTrait: StateTransformTrait<BuyCryptoState>,
                                                                didSelectFiat: ControlEvent<BuyCryptoPresenter.AssetViewModel>,
                                                                didSelectCrypto: ControlEvent<BuyCryptoPresenter.AssetViewModel>) {
            let combinedSelectingItems = Observable.combineLatest(didSelectFiat.asObservable(), didSelectCrypto.asObservable())
                .filteredByState(stateTransformTrait.readOnlyState) { state -> Bool in
                    switch state {
                    case .aCashAssetsLoaded: return true
                    default: return false
                    }
                }
        }

        static func fromCheckingExchangePairToCheckingExchangePairError(stateTransformTrait: StateTransformTrait<BuyCryptoState>,
                                                                        checkingExchangePairError: Observable<Error>) {
            let fromCheckingExchangePairToCheckingExchangePairError = checkingExchangePairError
                .filteredByState(stateTransformTrait.readOnlyState) { state -> Bool in
                    switch state {
                    case .checkingExchangePair: return true
                    default: return false
                    }
                }
                .map { BuyCryptoState.checkingExchangePairError($0) }

            fromCheckingExchangePairToCheckingExchangePairError
                .bind(to: stateTransformTrait._state)
                .disposed(by: stateTransformTrait.disposeBag)
        }
    }
}
