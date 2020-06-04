//
//  BuyCryptoInteractor+StateTransform.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 03.06.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import AppTools
import DomainLayer
import RxCocoa
import RxSwift

extension BuyCryptoInteractor {
    enum StateTransform {
        static func performTransformations(stateTransformTrait: StateTransformTrait<BuyCryptoState>,
                                           viewOutput: BuyCryptoViewOutput,
                                           apiResponse: ApiResponse,
                                           internalActions: InternalActions,
                                           stateTransformActions: StateTransformActions) {
            fromIsLoadingToACashAssetsLoaded(stateTransformTrait: stateTransformTrait,
                                             didLoadACashAssets: apiResponse.didLoadACashAssets)

            fromIsLoadingToLoadingError(stateTransformTrait: stateTransformTrait,
                                        aCashAssetsLoadingError: apiResponse.aCashAssetsLoadingError)

            fromLoadingErrorToIsLoading(stateTransformTrait: stateTransformTrait,
                                        didTapRetry: viewOutput.didTapRetry,
                                        loadingEntryAction: stateTransformActions.initialLoadingEntryAction)

            fromACashAssetsLoadedToCheckingExchangePair(stateTransformTrait: stateTransformTrait,
                                                        didSelectFiat: viewOutput.didSelectFiatItem,
                                                        didSelectCrypto: viewOutput.didSelectCryptoItem,
                                                        didChangeFiatAmount: viewOutput.didChangeFiatAmount,
                                                        checkingPairAction: stateTransformActions.checkingExchangePairEntryAction)

            fromCheckingExchangePairToCheckingError(stateTransformTrait: stateTransformTrait,
                                                    checkingExchangePairError: apiResponse.checkingExchangePairError)

            fromCheckingErrorToCheckingExchangePair(stateTransformTrait: stateTransformTrait,
                                                    didTapRetry: viewOutput.didTapRetry)

            fromCheckingExchangeToReadyExchange(stateTransformTrait: stateTransformTrait,
                                                didCheckedExchangePair: apiResponse.didCheckedExchangePair)

            fromReadyToExchangeToCheckingExchangePair(stateTransformTrait: stateTransformTrait,
                                                      didLoadACashAssets: apiResponse.didLoadACashAssets,
                                                      didSelectFiat: viewOutput.didSelectFiatItem,
                                                      didSelectCrypto: viewOutput.didSelectCryptoItem,
                                                      didChangeFiatAmount: viewOutput.didChangeFiatAmount,
                                                      checkingPairAction: stateTransformActions.checkingExchangePairEntryAction)

            fromReadyToExchangeToExchangeProcessing(stateTransformTrait: stateTransformTrait,
                                                    didTapBuy: viewOutput.didTapBuy,
                                                    didChangeFiatAmount: viewOutput.didChangeFiatAmount,
                                                    processingEntryAction: stateTransformActions.processingEntryAction)

            fromExchangeProcessingToExchangeInProgress(stateTransformTrait: stateTransformTrait,
                                                       didProcessedExchange: apiResponse.didProcessedExchange,
                                                       openUrlEntryAction: stateTransformActions.openUrlEntryAction)

            fromExchangeInProgressToReadyForExchange(stateTransformTrait: stateTransformTrait,
                                                     didClosedWebView: internalActions.didClosedWebView)

            fromReadyForExchangeToCheckingExchangePair(
                stateTransformTrait: stateTransformTrait,
                didChangeFiatAmount: viewOutput.didChangeFiatAmount,
                checkingExchangePairEntryAction: stateTransformActions.checkingExchangePairEntryAction)
        }

        private static func fromIsLoadingToACashAssetsLoaded(stateTransformTrait: StateTransformTrait<BuyCryptoState>,
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

        private static func fromIsLoadingToLoadingError(stateTransformTrait: StateTransformTrait<BuyCryptoState>,
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

        private static func fromLoadingErrorToIsLoading(stateTransformTrait: StateTransformTrait<BuyCryptoState>,
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
        
        private static func fromACashAssetsLoadedToCheckingExchangePair(
            stateTransformTrait: StateTransformTrait<BuyCryptoState>,
            didSelectFiat: ControlEvent<BuyCryptoPresenter.AssetViewModel>,
            didSelectCrypto: ControlEvent<BuyCryptoPresenter.AssetViewModel>,
            didChangeFiatAmount: ControlEvent<String?>,
            checkingPairAction: @escaping (FiatAsset, CryptoAsset, Double) -> Void) {
            let amount = didChangeFiatAmount.map { Double($0 ?? "0") }

            let fromACashAssetsLoadedToCheckingExchangePair = Observable.combineLatest(didSelectFiat.asObservable(),
                                                                                       didSelectCrypto.asObservable())
                .filteredByState(stateTransformTrait.readOnlyState) { state -> AssetsInfo? in
                    switch state {
                    case .aCashAssetsLoaded(let assets): return assets
                    default: return nil
                    }
                }
                .denestifyTuple()
                .withLatestFrom(amount, resultSelector: { assetInfoFromState, fiatAmount -> (FiatAsset, CryptoAsset, Double) in
                    let (fiatItemVM, cryptoItemVM, assetInfo) = assetInfoFromState
                    let fiatAsset = assetInfo.fiatAssets.first(where: { $0.id == fiatItemVM.id })!
                    let cryptoAsset = assetInfo.cryptoAssets.first(where: { $0.id == cryptoItemVM.id })!
                    return (fiatAsset, cryptoAsset, fiatAmount ?? 0)
                })
                .map { BuyCryptoState.checkingExchangePair(senderAsset: $0, recipientAsset: $1, amount: $2) }
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

        private static func fromCheckingExchangePairToCheckingError(stateTransformTrait: StateTransformTrait<BuyCryptoState>,
                                                                    checkingExchangePairError: Observable<Error>) {
            let fromCheckingExchangePairToCheckingExchangePairError = checkingExchangePairError
                .filteredByState(stateTransformTrait.readOnlyState) { state -> (FiatAsset, CryptoAsset, Double)? in
                    switch state {
                    case let .checkingExchangePair(senderAsset, recipientAsset, amount):
                        return (senderAsset, recipientAsset, amount)
                    default: return nil
                    }
                }
                .denestifyTuple()
                .map { BuyCryptoState.checkingExchangePairError(error: $0, senderAsset: $1, recipientAsset: $2, amount: $3) }

            fromCheckingExchangePairToCheckingExchangePairError
                .bind(to: stateTransformTrait._state)
                .disposed(by: stateTransformTrait.disposeBag)
        }

        private static func fromCheckingErrorToCheckingExchangePair(stateTransformTrait: StateTransformTrait<BuyCryptoState>,
                                                                    didTapRetry: ControlEvent<Void>) {
            let fromCheckingErrorToCheckingExchangePair = didTapRetry
                .filteredByState(stateTransformTrait.readOnlyState) { state -> (FiatAsset, CryptoAsset, Double)? in
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

        private static func fromCheckingExchangeToReadyExchange(stateTransformTrait: StateTransformTrait<BuyCryptoState>,
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

        private static func fromReadyToExchangeToCheckingExchangePair(
            stateTransformTrait: StateTransformTrait<BuyCryptoState>,
            didLoadACashAssets: Observable<AssetsInfo>,
            didSelectFiat: ControlEvent<BuyCryptoPresenter.AssetViewModel>,
            didSelectCrypto: ControlEvent<BuyCryptoPresenter.AssetViewModel>,
            didChangeFiatAmount: ControlEvent<String?>,
            checkingPairAction: @escaping (FiatAsset, CryptoAsset, Double) -> Void) {
            let fromACashAssetsLoadedToCheckingExchangePair = Observable.combineLatest(didSelectFiat.asObservable(),
                                                                                       didSelectCrypto.asObservable(),
                                                                                       didLoadACashAssets)
                .filteredByState(stateTransformTrait.readOnlyState) { state -> Bool in
                    switch state {
                    case .readyForExchange: return true
                    default: return false
                    }
                }
                .withLatestFrom(didChangeFiatAmount.asObservable(), resultSelector: { assetsInfo, amount
                    -> (FiatAsset, CryptoAsset, Double) in
                    let (fiatItemVM, cryptoItemVM, loadedAssetsInfo) = assetsInfo
                    
                    let amount = amount.map { Double($0) ?? 0 } ?? 0
                    let fiatAsset = loadedAssetsInfo.fiatAssets.first(where: { $0.id == fiatItemVM.id })!
                    let cryptoAsset = loadedAssetsInfo.cryptoAssets.first(where: { $0.id == cryptoItemVM.id })!
                    
                    return (fiatAsset, cryptoAsset, amount)
                })
                .map { BuyCryptoState.checkingExchangePair(senderAsset: $0, recipientAsset: $1, amount: $2) }
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

        private static func fromReadyToExchangeToExchangeProcessing(
            stateTransformTrait: StateTransformTrait<BuyCryptoState>,
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

        private static func fromExchangeProcessingToExchangeInProgress(stateTransformTrait: StateTransformTrait<BuyCryptoState>,
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

        private static func fromExchangeInProgressToReadyForExchange(stateTransformTrait: StateTransformTrait<BuyCryptoState>,
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

        private static func fromReadyForExchangeToCheckingExchangePair(
            stateTransformTrait: StateTransformTrait<BuyCryptoState>,
            didChangeFiatAmount: ControlEvent<String?>,
            checkingExchangePairEntryAction: @escaping (FiatAsset, CryptoAsset, Double) -> Void) {
            let amount = didChangeFiatAmount.compactMap().map { Double($0) }.compactMap()

            let fromReadyForExchangeToCheckingExchangePair = amount
                .filteredByState(stateTransformTrait.readOnlyState) { state -> ExchangeInfo? in
                    switch state {
                    case let .readyForExchange(exchangeInfo): return exchangeInfo
                    default: return nil
                    }
                }
                .map {
                    BuyCryptoState
                        .checkingExchangePair(senderAsset: $1.senderAsset, recipientAsset: $1.recipientAsset, amount: $0)
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
