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

    private let stateTransformTrait: StateTransformTrait<BuyCryptoState>

    private let apiResponse = ApiResponse()

    private let disposeBag = DisposeBag()

    init(presenter: BuyCryptoPresentable) {
        self.presenter = presenter

        let _state = BehaviorRelay<BuyCryptoState>(value: .isLoading)
        stateTransformTrait = StateTransformTrait(_state: _state, disposeBag: disposeBag)
    }

    private func performInitialLoading() {}
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

        return BuyCryptoInteractorOutput(readOnlyState: stateTransformTrait.readOnlyState)
    }
}

extension BuyCryptoInteractor {
    private enum StateTransform {
        static func fromIsLoadingToACashAssetsLoaded(stateTransformTrait: StateTransformTrait<BuyCryptoState>,
                                                     didLoadACashAssets: Observable<Void>) {}

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
    private final class Networker {
        private let serverEnvironmentRepository: ServerEnvironmentRepository
        private let authorizationService: AuthorizationUseCaseProtocol
        private let oauthRepository: WEOAuthRepositoryProtocol
        private let gatewaysWavesRepository: GatewaysWavesRepository

        init(serverEnvironmentRepository: ServerEnvironmentRepository,
             authorizationService: AuthorizationUseCaseProtocol,
             oauthRepository: WEOAuthRepositoryProtocol,
             gatewaysWavesRepository: GatewaysWavesRepository) {
            self.serverEnvironmentRepository = serverEnvironmentRepository
            self.authorizationService = authorizationService
            self.oauthRepository = oauthRepository
            self.gatewaysWavesRepository = gatewaysWavesRepository
        }

        func getAssetsBindings() -> Observable<[GatewaysAssetBinding]> {
            Observable.zip(authorizationService.authorizedWallet(), serverEnvironmentRepository.serverEnvironment())
                .flatMap { [weak self] signedWallet, serverEnvironment -> Observable<(WEOAuthTokenDTO, ServerEnvironment)> in
                    guard let sself = self else { return Observable.never() }

                    return sself.obtainOAuthTokenWithServerEnvironment(signedWallet: signedWallet,
                                                                       serverEnvironment: serverEnvironment)
                }
                .flatMap { [weak self] token, serverEnvironment -> Observable<[GatewaysAssetBinding]> in
                    guard let sself = self else { return Observable.never() }
                    let request = AssetBindingsRequest(direction: .deposit)

                    return sself.gatewaysWavesRepository.assetBindingsRequest(serverEnvironment: serverEnvironment,
                                                                              oAToken: token,
                                                                              request: request)
                }
        }

        private func obtainOAuthTokenWithServerEnvironment(signedWallet: SignedWallet, serverEnvironment: ServerEnvironment)
            -> Observable<(WEOAuthTokenDTO, ServerEnvironment)> {
            oauthRepository.oauthToken(signedWallet: signedWallet)
                .map { token -> (WEOAuthTokenDTO, ServerEnvironment) in (token, serverEnvironment) }
        }
    }
}
