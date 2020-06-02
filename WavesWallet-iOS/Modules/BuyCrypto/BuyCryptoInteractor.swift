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
    weak var listener: BuyCryptoListener?

    private let presenter: BuyCryptoPresentable

    private let networker: Networker

    private let stateTransformTrait: StateTransformTrait<BuyCryptoState>

    private let apiResponse = ApiResponse()

    private let internalActions = InternalActions()

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

    private func checkingExchangePair(senderAsset: String, recipientAsset: String, amount: Double) {
        networker
            .getExchangeRate(senderAsset: senderAsset, recipientAsset: recipientAsset, amount: amount) { [weak self] result in
                switch result {
                case let .success(exchangeInfo): self?.apiResponse.$didCheckedExchangePair.accept(exchangeInfo)
                case let .failure(error): self?.apiResponse.$checkingExchangePairError.accept(error)
                }
            }
    }

    private func performDepositeProcessing(amount: String, exchangeInfo: ExchangeInfo) {
        let amount = Double(amount) ?? 0

        networker.deposite(senderAsset: exchangeInfo.senderAsset,
                           recipientAsset: exchangeInfo.recipientAsset,
                           exchangeAddress: exchangeInfo.exchangeAddress,
                           amount: amount,
                           completion: { [weak self] result in
                               switch result {
                               case let .success(url): self?.apiResponse.$didProcessedExchange.accept(url)
                               case let .failure(error): self?.apiResponse.$processingExchangeError.accept(error)
                               }
        })
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

        let checkingExchangePairEntryAction: (String, String, Double) -> Void = { [weak self] in
            self?.checkingExchangePair(senderAsset: $0, recipientAsset: $1, amount: $2)
        }
        StateTransform.fromACashAssetsLoadedToCheckingExchangePair(stateTransformTrait: stateTransformTrait,
                                                                   didSelectFiat: input.didSelectFiatItem,
                                                                   didSelectCrypto: input.didSelectCryptoItem,
                                                                   didChangeFiatAmount: input.didChangeFiatAmount,
                                                                   checkingPairAction: checkingExchangePairEntryAction)

        StateTransform.fromCheckingExchangePairToCheckingError(stateTransformTrait: stateTransformTrait,
                                                               checkingExchangePairError: apiResponse.checkingExchangePairError)

        StateTransform.fromCheckingErrorToCheckingExchangePair(stateTransformTrait: stateTransformTrait,
                                                               didTapRetry: input.didTapRetry)

        StateTransform.fromCheckingExchangeToReadyExchange(stateTransformTrait: stateTransformTrait,
                                                           didCheckedExchangePair: apiResponse.didCheckedExchangePair)

        StateTransform.fromReadyToExchangeToCheckingExchangePair(stateTransformTrait: stateTransformTrait,
                                                                 didSelectFiat: input.didSelectFiatItem,
                                                                 didSelectCrypto: input.didSelectCryptoItem,
                                                                 didChangeFiatAmount: input.didChangeFiatAmount,
                                                                 checkingPairAction: checkingExchangePairEntryAction)

        let processingEntryAction: (String, ExchangeInfo) -> Void = { [weak self] in
            self?.performDepositeProcessing(amount: $0, exchangeInfo: $1)
        }
        StateTransform.fromReadyToExchangeToExchangeProcessing(stateTransformTrait: stateTransformTrait,
                                                               didTapBuy: input.didTapBuy,
                                                               didChangeFiatAmount: input.didChangeFiatAmount,
                                                               processingEntryAction: processingEntryAction)

        let openUrlEntryAction: (URL) -> Void = { [weak self] url in
            DispatchQueue.main.async { [weak self] in
                guard let sself = self else { return }
                sself.listener?.openUrl(url, delegate: sself)
            }
        }
        StateTransform.fromExchangeProcessingToExchangeInProgress(stateTransformTrait: stateTransformTrait,
                                                                  didProcessedExchange: apiResponse.didProcessedExchange,
                                                                  openUrlEntryAction: openUrlEntryAction)

        StateTransform.fromExchangeInProgressToReadyForExchange(stateTransformTrait: stateTransformTrait,
                                                                didClosedWebView: internalActions.didClosedWebView)

        StateTransform.fromReadyForExchangeToCheckingExchangePair(stateTransformTrait: stateTransformTrait,
                                                                  didChangeFiatAmount: input.didChangeFiatAmount,
                                                                  checkingExchangePairEntryAction: checkingExchangePairEntryAction)

        // костылик, надо будет подумать как это нормально сделать
        // когда происходит прокручивание ассета число сбрасывать или оставлять это и делать пересчет?
        let validationError = Helper.makeValidationFiatAmount(readOnlyState: stateTransformTrait.readOnlyState,
                                                              didChangeFiatAmount: input.didChangeFiatAmount)

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
                                                                didChangeFiatAmount: ControlEvent<String?>,
                                                                checkingPairAction: @escaping (String, String, Double) -> Void) {
            let amount = didChangeFiatAmount.map { Double($0 ?? "0") }

            let fromACashAssetsLoadedToCheckingExchangePair = Observable.combineLatest(didSelectFiat.asObservable(),
                                                                                       didSelectCrypto.asObservable())
                .filteredByState(stateTransformTrait.readOnlyState) { state -> Bool in
                    switch state {
                    case .aCashAssetsLoaded: return true
                    default: return false
                    }
                }
                .withLatestFrom(amount, resultSelector: { selectedItems, fiatAmount
                        -> (BuyCryptoPresenter.AssetViewModel, BuyCryptoPresenter.AssetViewModel, Double) in
                    let (fiatItem, cryptoItem) = selectedItems
                    return (fiatItem, cryptoItem, fiatAmount ?? 0)
                })
                .map { BuyCryptoState.checkingExchangePair(senderAsset: $0.id, recipientAsset: $1.id, amount: $2) }
                .share()

            fromACashAssetsLoadedToCheckingExchangePair
                .bind(to: stateTransformTrait._state)
                .disposed(by: stateTransformTrait.disposeBag)

            fromACashAssetsLoadedToCheckingExchangePair
                .subscribe(onNext: { state in
                    switch state {
                    case let .checkingExchangePair(sender, recipient, amount): checkingPairAction(sender, recipient, amount)
                    default: return
                    }
                })
                .disposed(by: stateTransformTrait.disposeBag)
        }

        static func fromCheckingExchangePairToCheckingError(stateTransformTrait: StateTransformTrait<BuyCryptoState>,
                                                            checkingExchangePairError: Observable<Error>) {
            let fromCheckingExchangePairToCheckingExchangePairError = checkingExchangePairError
                .filteredByState(stateTransformTrait.readOnlyState) { state -> (String, String, Double)? in
                    switch state {
                    case let .checkingExchangePair(senderAsset, recipientAsset, amount): return (senderAsset, recipientAsset,
                                                                                                 amount)
                    default: return nil
                    }
                }
                .denestifyTuple()
                .map { BuyCryptoState.checkingExchangePairError(error: $0, senderAsset: $1, recipientAsset: $2, amount: $3) }

            fromCheckingExchangePairToCheckingExchangePairError
                .bind(to: stateTransformTrait._state)
                .disposed(by: stateTransformTrait.disposeBag)
        }

        static func fromCheckingErrorToCheckingExchangePair(stateTransformTrait: StateTransformTrait<BuyCryptoState>,
                                                            didTapRetry: ControlEvent<Void>) {
            let fromCheckingErrorToCheckingExchangePair = didTapRetry
                .filteredByState(stateTransformTrait.readOnlyState) { state -> (String, String, Double)? in
                    switch state {
                    case let .checkingExchangePairError(_, senderAsset, recipientAsset, amount):
                        return (senderAsset, recipientAsset, amount)
                    default: return nil
                    }
                }
                .denestifyTuple()
                .map { BuyCryptoState.checkingExchangePair(senderAsset: $1, recipientAsset: $2, amount: $3) }

            fromCheckingErrorToCheckingExchangePair
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
                                                              didChangeFiatAmount: ControlEvent<String?>,
                                                              checkingPairAction: @escaping (String, String, Double) -> Void) {
            let fromACashAssetsLoadedToCheckingExchangePair = Observable.combineLatest(didSelectFiat.asObservable(),
                                                                                       didSelectCrypto.asObservable())
                .filteredByState(stateTransformTrait.readOnlyState) { state -> Bool in
                    switch state {
                    case .readyForExchange: return true
                    default: return false
                    }
                }
                .withLatestFrom(didChangeFiatAmount.asObservable(), resultSelector: { selectedItems, amount
                        -> (BuyCryptoPresenter.AssetViewModel, BuyCryptoPresenter.AssetViewModel, Double) in
                    let (fiatItem, cryptoItem) = selectedItems
                    let amount = amount.map { Double($0) ?? 0 } ?? 0

                    return (fiatItem, cryptoItem, amount)
                })
                .map { BuyCryptoState.checkingExchangePair(senderAsset: $0.id, recipientAsset: $1.id, amount: $2) }
                .share()

            fromACashAssetsLoadedToCheckingExchangePair
                .bind(to: stateTransformTrait._state)
                .disposed(by: stateTransformTrait.disposeBag)

            fromACashAssetsLoadedToCheckingExchangePair
                .subscribe(onNext: { state in
                    switch state {
                    case let .checkingExchangePair(sender, recipient, amount): checkingPairAction(sender, recipient, amount)
                    default: return
                    }
                })
                .disposed(by: stateTransformTrait.disposeBag)
        }

        static func fromReadyToExchangeToExchangeProcessing(stateTransformTrait: StateTransformTrait<BuyCryptoState>,
                                                            didTapBuy: ControlEvent<Void>,
                                                            didChangeFiatAmount: ControlEvent<String?>,
                                                            processingEntryAction: @escaping (String, ExchangeInfo) -> Void) {
            let fromReadyToExchangeToExchangeProcessing = didTapBuy
                .filteredByState(stateTransformTrait.readOnlyState) { state -> ExchangeInfo? in
                    switch state {
                    case let .readyForExchange(exchangeInfo): return exchangeInfo
                    default: return nil
                    }
                }
                .withLatestFrom(didChangeFiatAmount.compactMap(), resultSelector: { args, amount in
                    let (_, info) = args
                    return (info, amount)
                })
                .map { BuyCryptoState.processingExchange(amount: $1, exchangeInfo: $0) }
                .share()

            fromReadyToExchangeToExchangeProcessing
                .bind(to: stateTransformTrait._state)
                .disposed(by: stateTransformTrait.disposeBag)

            fromReadyToExchangeToExchangeProcessing
                .subscribe(onNext: { state in
                    switch state {
                    case let .processingExchange(amount, exchangeInfo): processingEntryAction(amount, exchangeInfo)
                    default: return
                    }
                })
                .disposed(by: stateTransformTrait.disposeBag)
        }

        static func fromExchangeProcessingToExchangeInProgress(stateTransformTrait: StateTransformTrait<BuyCryptoState>,
                                                               didProcessedExchange: Observable<URL>,
                                                               openUrlEntryAction: @escaping (URL) -> Void) {
            let fromExchangeProcessingToExchangeInProgress = didProcessedExchange
                .filteredByState(stateTransformTrait.readOnlyState) { state -> ExchangeInfo? in
                    switch state {
                    case let .processingExchange(_, exchangeInfo): return exchangeInfo
                    default: return nil
                    }
                }
                .map { BuyCryptoState.exchangeInProgress(url: $0, exchangeInfo: $1) }
                .share()

            fromExchangeProcessingToExchangeInProgress
                .bind(to: stateTransformTrait._state)
                .disposed(by: stateTransformTrait.disposeBag)

            fromExchangeProcessingToExchangeInProgress
                .subscribe(onNext: { state in
                    switch state {
                    case let .exchangeInProgress(url, _): openUrlEntryAction(url)
                    default: return
                    }
                }).disposed(by: stateTransformTrait.disposeBag)
        }

        static func fromExchangeInProgressToReadyForExchange(stateTransformTrait: StateTransformTrait<BuyCryptoState>,
                                                             didClosedWebView: Observable<Void>) {
            let fromExchangeInProgressToReadyForExchange = didClosedWebView
                .filteredByState(stateTransformTrait.readOnlyState) { state -> ExchangeInfo? in
                    switch state {
                    case let .exchangeInProgress(_, exchangeInfo): return exchangeInfo
                    default: return nil
                    }
                }
                .map { BuyCryptoState.readyForExchange($1) }

            fromExchangeInProgressToReadyForExchange
                .bind(to: stateTransformTrait._state)
                .disposed(by: stateTransformTrait.disposeBag)
        }

        static func fromReadyForExchangeToCheckingExchangePair(stateTransformTrait: StateTransformTrait<BuyCryptoState>,
                                                               didChangeFiatAmount: ControlEvent<String?>,
                                                               checkingExchangePairEntryAction: @escaping (String, String,
                                                                                                           Double) -> Void) {
            let amount = didChangeFiatAmount.compactMap().map { Double($0) }.compactMap()

            let fromReadyForExchangeToCheckingExchangePair = amount
                .filteredByState(stateTransformTrait.readOnlyState) { state -> ExchangeInfo? in
                    switch state {
                    case let .readyForExchange(exchangeInfo): return exchangeInfo
                    default: return nil
                    }
                }
                .map { amount, info in
                    BuyCryptoState
                        .checkingExchangePair(senderAsset: info.senderAsset, recipientAsset: info.recipientAsset, amount: amount)
                }
                .share()

            fromReadyForExchangeToCheckingExchangePair
                .bind(to: stateTransformTrait._state)
                .disposed(by: stateTransformTrait.disposeBag)

            fromReadyForExchangeToCheckingExchangePair
                .subscribe(onNext: { state in
                    switch state {
                    case let .checkingExchangePair(senderAsset, recipientAsset, amount):
                        checkingExchangePairEntryAction(senderAsset, recipientAsset, amount)
                    default: return
                    }
                })
                .disposed(by: stateTransformTrait.disposeBag)
        }
    }
}

extension BuyCryptoInteractor: BrowserViewControllerDelegate {
    func browserViewRedirect(_: BrowserViewController, url: URL) {
        let link = url.absoluteStringByTrimmingQuery() ?? ""

        if link.contains(DomainLayerConstants.URL.fiatDepositSuccess) {
            internalActions.$exchangeSuccessful.accept(Void())
        } else if link.contains(DomainLayerConstants.URL.fiatDepositFail) {
            internalActions.$exchangeFailed.accept(Void())
        }
    }

    func browserViewDismissed(_: BrowserViewController) {
        internalActions.$didClosedWebView.accept(Void())
    }
}

extension BuyCryptoInteractor {
    private enum Helper {
        static func makeValidationFiatAmount(readOnlyState: Observable<BuyCryptoState>,
                                             didChangeFiatAmount: ControlEvent<String?>) -> Signal<Error?> {
            Observable.combineLatest(didChangeFiatAmount.asObservable(), readOnlyState)
                .map { optionalFiatAmount, state -> Error? in
                    switch state {
                    case let .readyForExchange(exchangeInfo):
                        guard let fiatAmount = optionalFiatAmount, !fiatAmount.isEmpty else { return nil }

                        guard let fiatAmountNumber = Decimal(string: fiatAmount) else {
                            return FiatAmountValidationError.isNaN
                        }

                        if fiatAmountNumber > exchangeInfo.maxLimit {
                            return FiatAmountValidationError.moreMax(max: exchangeInfo.maxLimit)
                        } else if fiatAmountNumber < exchangeInfo.minLimit {
                            return FiatAmountValidationError.lessMin(min: exchangeInfo.minLimit)
                        } else {
                            return nil
                        }
                    default: return nil
                    }
                }
                .asSignalIgnoringError()
        }
    }
}
