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
         serverEnvironmentRepository: ServerEnvironmentRepository,
         weOAuthRepository: WEOAuthRepositoryProtocol) {
        self.presenter = presenter

        let _state = BehaviorRelay<BuyCryptoState>(value: .isLoading)
        stateTransformTrait = StateTransformTrait(_state: _state, disposeBag: disposeBag)

        networker = Networker(authorizationService: authorizationService,
                              environmentRepository: environmentRepository,
                              gatewaysWavesRepository: gatewayWavesRepository,
                              assetsUseCase: assetsUseCase,
                              adCashGRPCService: adCashGRPCService,
                              developmentConfigRepository: developmentConfigRepository,
                              serverEnvironmentRepository: serverEnvironmentRepository,
                              weOAuthRepository: weOAuthRepository)
    }

    private func performInitialLoading() {
        networker.getAssets { [weak self] result in
            switch result {
            case let .success(assets): self?.apiResponse.$didLoadACashAssets.accept(assets)
            case let .failure(error): self?.apiResponse.$aCashAssetsLoadingError.accept(error)
            }
        }
    }

    private func checkingExchangePair(senderAsset: String, recipientAsset: String) {
        networker.getExchangeRate(senderAsset: senderAsset, recipientAsset: recipientAsset) { [weak self] result in
            switch result {
            case .success(let exchangeInfo): self?.apiResponse.$didCheckedExchangePair.accept(exchangeInfo)
            case let .failure(error): self?.apiResponse.$checkingExchangePairError.accept(error)
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

        let loadingEntryAction: VoidClosure = { [weak self] in
            self?.performInitialLoading()
        }
        StateTransform.fromLoadingErrorToIsLoading(stateTransformTrait: stateTransformTrait,
                                                   didTapRetry: input.didTapRetry,
                                                   loadingEntryAction: loadingEntryAction)

        let checkingExchangePairEntryAction: (_ senderAsset: String, _ recipientAsset: String) -> Void = { [weak self] in
            self?.checkingExchangePair(senderAsset: $0, recipientAsset: $1)
        }
        StateTransform.fromACashAssetsLoadedToCheckingExchangePair(stateTransformTrait: stateTransformTrait,
                                                                   didSelectFiat: input.didSelectFiatItem,
                                                                   didSelectCrypto: input.didSelectCryptoItem,
                                                                   checkingPairAction: checkingExchangePairEntryAction)

        StateTransform.fromCheckingExchangePairToCheckingError(stateTransformTrait: stateTransformTrait,
                                                               checkingExchangePairError: apiResponse.checkingExchangePairError)

        StateTransform.fromCheckingExchangeToReadyExchange(stateTransformTrait: stateTransformTrait,
                                                           didCheckedExchangePair: apiResponse.didCheckedExchangePair)

        StateTransform.fromReadyToExchangeToCheckingExchangePair(stateTransformTrait: stateTransformTrait,
                                                                 didSelectFiat: input.didSelectFiatItem,
                                                                 didSelectCrypto: input.didSelectCryptoItem,
                                                                 checkingPairAction: checkingExchangePairEntryAction)
        
        // костылик, надо будет подумать как это нормально сделать
        // когда происходит прокручивание ассета число сбрасывать или оставлять это и делать пересчет?
        let validationError = input.didChangeFiatAmount
            .filteredByState(stateTransformTrait.readOnlyState) { state -> ExchangeInfo? in
                switch state {
                case .readyForExchange(let exchangeInfo): return exchangeInfo
                default: return nil
                }
        }
        .map { optionalFiatAmount, exchangeInfo -> Error? in
            guard let fiatAmount = optionalFiatAmount, !fiatAmount.isEmpty else { return nil }
            
            guard  let fiatAmountNumber = Decimal(string: fiatAmount) else {
                return FiatAmountValidationError.isNaN
            }
            
            if fiatAmountNumber > exchangeInfo.maxLimit {
                return FiatAmountValidationError.moreMax(max: exchangeInfo.maxLimit)
            } else if fiatAmountNumber < exchangeInfo.minLimit {
                return FiatAmountValidationError.lessMin(min: exchangeInfo.minLimit)
            } else {
                return nil
            }
        }
        .asSignalIgnoringError()

        // didSelectFiatItem и didSelectCryptoItem проходят транзитом через интерактор
        // в presenter необходимо изменять title(ы) на лейблах и кнопке
        return BuyCryptoInteractorOutput(readOnlyState: stateTransformTrait.readOnlyState,
                                         didSelectFiatItem: input.didSelectFiatItem,
                                         didSelectCryptoItem: input.didSelectCryptoItem,
                                         didChangeFiatAmount: input.didChangeFiatAmount,
                                         validationError: validationError)
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
                                                didTapRetry: ControlEvent<Void>,
                                                loadingEntryAction: @escaping VoidClosure) {
            let fromLoadingErrorToIsLoading = didTapRetry
                .filteredByState(stateTransformTrait.readOnlyState) { state -> Bool in
                    switch state {
                    case .loadingError: return true
                    default: return false
                    }
                }
                .map { BuyCryptoState.isLoading }
                .share()

            fromLoadingErrorToIsLoading
                .bind(to: stateTransformTrait._state)
                .disposed(by: stateTransformTrait.disposeBag)

            fromLoadingErrorToIsLoading
                .subscribe(onNext: { _ in loadingEntryAction() })
                .disposed(by: stateTransformTrait.disposeBag)
        }

        static func fromACashAssetsLoadedToCheckingExchangePair(stateTransformTrait: StateTransformTrait<BuyCryptoState>,
                                                                didSelectFiat: ControlEvent<BuyCryptoPresenter.AssetViewModel>,
                                                                didSelectCrypto: ControlEvent<BuyCryptoPresenter.AssetViewModel>,
                                                                checkingPairAction: @escaping (String, String) -> Void) {
            let fromACashAssetsLoadedToCheckingExchangePair = Observable.combineLatest(didSelectFiat.asObservable(),
                                                                                       didSelectCrypto.asObservable())
                .filteredByState(stateTransformTrait.readOnlyState) { state -> Bool in
                    switch state {
                    case .aCashAssetsLoaded: return true
                    default: return false
                    }
                }
                .map { BuyCryptoState.checkingExchangePair(senderAsset: $0.id, recipientAsset: $1.id) }
                .share()

            fromACashAssetsLoadedToCheckingExchangePair
                .bind(to: stateTransformTrait._state)
                .disposed(by: stateTransformTrait.disposeBag)

            fromACashAssetsLoadedToCheckingExchangePair
                .subscribe(onNext: { state in
                    switch state {
                    case let .checkingExchangePair(sender, recipient): checkingPairAction(sender, recipient)
                    default: return
                    }
                })
                .disposed(by: stateTransformTrait.disposeBag)
        }

        static func fromCheckingExchangePairToCheckingError(stateTransformTrait: StateTransformTrait<BuyCryptoState>,
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

        static func fromCheckingExchangeToReadyExchange(stateTransformTrait: StateTransformTrait<BuyCryptoState>,
                                                        didCheckedExchangePair: Observable<ExchangeInfo>) {
            let fromCheckingExchangeToReadyExchange = didCheckedExchangePair
                .filteredByState(stateTransformTrait.readOnlyState) { state -> Bool in
                    switch state {
                    case .checkingExchangePair: return true
                    default: return false
                    }
                }
                .map { BuyCryptoState.readyForExchange($0) }

            fromCheckingExchangeToReadyExchange
                .bind(to: stateTransformTrait._state)
                .disposed(by: stateTransformTrait.disposeBag)
        }

        static func fromReadyToExchangeToCheckingExchangePair(stateTransformTrait: StateTransformTrait<BuyCryptoState>,
                                                              didSelectFiat: ControlEvent<BuyCryptoPresenter.AssetViewModel>,
                                                              didSelectCrypto: ControlEvent<BuyCryptoPresenter.AssetViewModel>,
                                                              checkingPairAction: @escaping (String, String) -> Void) {
            let fromACashAssetsLoadedToCheckingExchangePair = Observable.combineLatest(didSelectFiat.asObservable(),
                                                                                       didSelectCrypto.asObservable())
                .filteredByState(stateTransformTrait.readOnlyState) { state -> Bool in
                    switch state {
                    case .readyForExchange: return true
                    default: return false
                    }
                }
                .map { BuyCryptoState.checkingExchangePair(senderAsset: $0.name, recipientAsset: $1.name) }
                .share()

            fromACashAssetsLoadedToCheckingExchangePair
                .bind(to: stateTransformTrait._state)
                .disposed(by: stateTransformTrait.disposeBag)

            fromACashAssetsLoadedToCheckingExchangePair
                .subscribe(onNext: { state in
                    switch state {
                    case let .checkingExchangePair(sender, recipient): checkingPairAction(sender, recipient)
                    default: return
                    }
                })
                .disposed(by: stateTransformTrait.disposeBag)
        }
    }
}

extension BuyCryptoInteractor {
    private enum Helper {
        static func makeValidationFiatAmount(readOnlyState: Observable<BuyCryptoState>,
                                             didChangeFiatAmount: ControlEvent<String?>) -> Signal<Error?> {
            didChangeFiatAmount
                .filteredByState(readOnlyState) { state -> ExchangeInfo? in
                    switch state {
                    case .readyForExchange(let exchangeInfo): return exchangeInfo
                    default: return nil
                    }
            }
            .map { optionalFiatAmount, exchangeInfo -> Error? in
                guard let fiatAmount = optionalFiatAmount, !fiatAmount.isEmpty else { return nil }
                
                guard  let fiatAmountNumber = Decimal(string: fiatAmount) else {
                    return FiatAmountValidationError.isNaN
                }
                
                if fiatAmountNumber > exchangeInfo.maxLimit {
                    return FiatAmountValidationError.moreMax(max: exchangeInfo.maxLimit)
                } else if fiatAmountNumber < exchangeInfo.minLimit {
                    return FiatAmountValidationError.lessMin(min: exchangeInfo.minLimit)
                } else {
                    return nil
                }
            }
            .asSignalIgnoringError()
        }
    }
}
