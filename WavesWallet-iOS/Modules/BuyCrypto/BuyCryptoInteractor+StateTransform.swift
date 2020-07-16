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
                                                        didSelectPaymentMethod: viewOutput.didSelectPaymentMethod,
                                                        checkingPairAction: stateTransformActions.checkingExchangePairEntryAction)

            fromCheckingExchangePairToCheckingError(stateTransformTrait: stateTransformTrait,
                                                    checkingExchangePairError: apiResponse.checkingExchangePairError)

            fromCheckingErrorToCheckingExchangePair(stateTransformTrait: stateTransformTrait,
                                                    didTapRetry: viewOutput.didTapRetry)

            fromCheckingExchangeToReadyExchange(stateTransformTrait: stateTransformTrait,
                                                didSelectFiat: viewOutput.didSelectFiatItem,
                                                didSelectCrypto: viewOutput.didSelectCryptoItem,
                                                didCheckedExchangePair: apiResponse.didCheckedExchangePair)

            fromCheckingExchangeToCheckingExchange(stateTransformTrait: stateTransformTrait,
                                                   didLoadACashAssets: apiResponse.didLoadACashAssets,
                                                   didSelectFiatItem: viewOutput.didSelectFiatItem,
                                                   didSelectCryptoItem: viewOutput.didSelectCryptoItem,
                                                   didChangeFiatAmount: viewOutput.didChangeFiatAmount,
                                                   checkingPairAction: stateTransformActions.checkingExchangePairEntryAction)

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
        }

        private static func fromIsLoadingToACashAssetsLoaded(stateTransformTrait: StateTransformTrait<BuyCryptoState>,
                                                             didLoadACashAssets: Observable<AssetsInfo>) {
            let fromIsLoadingToACashAssetsLoaded = didLoadACashAssets
                .withLatestFrom(stateTransformTrait.readOnlyState, resultSelector: latestFromBothValues())
                .compactMap { assetInfo, buyCryptoState -> BuyCryptoState? in
                    switch buyCryptoState.state {
                    case .isLoading: return buyCryptoState.copy(newState: .aCashAssetsLoaded(assetInfo))
                    default: return nil
                    }
                }

            fromIsLoadingToACashAssetsLoaded.bind(to: stateTransformTrait._state).disposed(by: stateTransformTrait.disposeBag)
        }

        private static func fromIsLoadingToLoadingError(stateTransformTrait: StateTransformTrait<BuyCryptoState>,
                                                        aCashAssetsLoadingError: Observable<Error>) {
            let fromIsLoadingToLoadingError = aCashAssetsLoadingError
                .withLatestFrom(stateTransformTrait.readOnlyState, resultSelector: latestFromBothValues())
                .compactMap { error, buyCryptoState -> BuyCryptoState? in
                    switch buyCryptoState.state {
                    case .isLoading: return buyCryptoState.copy(newState: .loadingError(error))
                    default: return nil
                    }
                }

            fromIsLoadingToLoadingError.bind(to: stateTransformTrait._state).disposed(by: stateTransformTrait.disposeBag)
        }

        private static func fromLoadingErrorToIsLoading(stateTransformTrait: StateTransformTrait<BuyCryptoState>,
                                                        didTapRetry: ControlEvent<Void>,
                                                        loadingEntryAction: @escaping VoidClosure) {
            let fromLoadingErrorToIsLoading = didTapRetry
                .withLatestFrom(stateTransformTrait.readOnlyState, resultSelector: latestFromBothValues())
                .compactMap { _, buyCryptoState -> BuyCryptoState? in
                    switch buyCryptoState.state {
                    case .loadingError: return buyCryptoState.copy(newState: .isLoading)
                    default: return nil
                    }
                }
                .do(afterNext: { _ in loadingEntryAction() })

            fromLoadingErrorToIsLoading
                .bind(to: stateTransformTrait._state)
                .disposed(by: stateTransformTrait.disposeBag)
        }

        private static func fromACashAssetsLoadedToCheckingExchangePair(
            stateTransformTrait: StateTransformTrait<BuyCryptoState>,
            didSelectFiat: ControlEvent<BuyCryptoPresenter.AssetViewModel>,
            didSelectCrypto: ControlEvent<BuyCryptoPresenter.AssetViewModel>,
            didChangeFiatAmount: ControlEvent<String?>,
            didSelectPaymentMethod: ControlEvent<PaymentMethod>,
            checkingPairAction: @escaping (FiatAsset, CryptoAsset, Double, PaymentMethod) -> Void) {
            let fiatAmount = didChangeFiatAmount.map { Double($0 ?? "0") ?? 0 }

            let fromACashAssetsLoadedToCheckingExchangePair = Observable
                .combineLatest(didSelectFiat.asObservable(), didSelectCrypto.asObservable(), fiatAmount, didSelectPaymentMethod)
                .withLatestFrom(stateTransformTrait.readOnlyState, resultSelector: latestFromBothValues())
                .compactMap { uiInput, buyCryptoState -> BuyCryptoState? in
                    let (fiatItemVM, cryptoItemVM, amount, paymentMethod) = uiInput
                    switch buyCryptoState.state {
                    case let .aCashAssetsLoaded(assetsInfo):
                        if let fiatAsset = assetsInfo.fiatAssets.first(where: { $0.id == fiatItemVM.id }),
                            let cryptoAsset = assetsInfo.cryptoAssets.first(where: { $0.id == cryptoItemVM.id }) {
                            return buyCryptoState.copy(newState: .checkingExchangePair(senderAsset: fiatAsset,
                                                                                       recipientAsset: cryptoAsset,
                                                                                       amount: amount,
                                                                                       paymentMethod: paymentMethod))
                        } else {
                            // из выбранных ассетов не может произойти так, что не найдет их.
                            // если такое происходит, то вероятно, где-то id мапиться не так (ищи где маппинг ac_idName и idName)
                            // пример: ac_usdn и usdn
                            return nil
                        }

                    default: return nil
                    }
                }
                .do(afterNext: { buyCryptoState in
                    switch buyCryptoState.state {
                    case let .checkingExchangePair(senderAsset, recipientAsset, amount, paymentMethod):
                        checkingPairAction(senderAsset, recipientAsset, amount, paymentMethod)

                    default: return
                    }
            })

            fromACashAssetsLoadedToCheckingExchangePair
                .bind(to: stateTransformTrait._state)
                .disposed(by: stateTransformTrait.disposeBag)
        }

        private static func fromCheckingExchangePairToCheckingError(stateTransformTrait: StateTransformTrait<BuyCryptoState>,
                                                                    checkingExchangePairError: Observable<Error>) {
            let fromCheckingExchangePairToCheckingExchangePairError = checkingExchangePairError
                .withLatestFrom(stateTransformTrait.readOnlyState, resultSelector: latestFromBothValues())
                .compactMap { error, buyCryptoState -> BuyCryptoState? in
                    switch buyCryptoState.state {
                    case let .checkingExchangePair(senderAsset, recipientAsset, amount, paymentMethod):
                        return buyCryptoState.copy(newState: .checkingExchangePairError(error: error,
                                                                                        senderAsset: senderAsset,
                                                                                        recipientAsset: recipientAsset,
                                                                                        amount: amount,
                                                                                        paymentMethod: paymentMethod))

                    default: return nil
                    }
                }

            fromCheckingExchangePairToCheckingExchangePairError
                .bind(to: stateTransformTrait._state)
                .disposed(by: stateTransformTrait.disposeBag)
        }

        private static func fromCheckingErrorToCheckingExchangePair(stateTransformTrait: StateTransformTrait<BuyCryptoState>,
                                                                    didTapRetry: ControlEvent<Void>) {
            let fromCheckingErrorToCheckingExchangePair = didTapRetry
                .withLatestFrom(stateTransformTrait.readOnlyState, resultSelector: latestFromBothValues())
                .compactMap { _, buyCryptoState -> BuyCryptoState? in
                    switch buyCryptoState.state {
                    case let .checkingExchangePairError(_, senderAsset, recipientAsset, amount, paymentMethod):
                        return buyCryptoState.copy(newState: .checkingExchangePair(senderAsset: senderAsset,
                                                                                   recipientAsset: recipientAsset,
                                                                                   amount: amount,
                                                                                   paymentMethod: paymentMethod))

                    default: return nil
                    }
                }

            fromCheckingErrorToCheckingExchangePair
                .bind(to: stateTransformTrait._state)
                .disposed(by: stateTransformTrait.disposeBag)
        }

        private static func fromCheckingExchangeToReadyExchange(stateTransformTrait: StateTransformTrait<BuyCryptoState>,
                                                                didSelectFiat: ControlEvent<BuyCryptoPresenter.AssetViewModel>,
                                                                didSelectCrypto: ControlEvent<BuyCryptoPresenter.AssetViewModel>,
                                                                didCheckedExchangePair: Observable<ExchangeInfo>) {
            let fromCheckingExchangeToReadyExchange = Observable
                .combineLatest(didSelectFiat, didSelectCrypto, didCheckedExchangePair)
                .withLatestFrom(stateTransformTrait.readOnlyState, resultSelector: latestFromBothValues())
                .denestifyTuple()
                .compactMap { fiatItem, cryptoItem, exchangeInfo, buyCryptoState -> BuyCryptoState? in
                    // необходимо для фильтра, когда ты выбрал какой-то из фиатных или крипто ассетов, но потом поменял выбор но запрос уже ушел
                    if fiatItem.id == exchangeInfo.senderAsset.id, cryptoItem.id == exchangeInfo.recipientAsset.id {
                        switch buyCryptoState.state {
                        case let .checkingExchangePair(_, _, _, paymentMethod):
                            return buyCryptoState.copy(newState: .readyForExchange(exchangeInfo, paymentMethod))
                        default: return nil
                        }
                    } else {
                        return nil
                    }
                }

            fromCheckingExchangeToReadyExchange
                .bind(to: stateTransformTrait._state)
                .disposed(by: stateTransformTrait.disposeBag)
        }

        private static func fromCheckingExchangeToCheckingExchange(
            stateTransformTrait: StateTransformTrait<BuyCryptoState>,
            didLoadACashAssets: Observable<AssetsInfo>,
            didSelectFiatItem: ControlEvent<BuyCryptoPresenter.AssetViewModel>,
            didSelectCryptoItem: ControlEvent<BuyCryptoPresenter.AssetViewModel>,
            didChangeFiatAmount: ControlEvent<String?>,
            checkingPairAction: @escaping (FiatAsset, CryptoAsset, Double, PaymentMethod) -> Void) {
            let fromCheckingExchangeToCheckingExchange = Observable
                .combineLatest(didSelectFiatItem.asObservable(),
                               didSelectCryptoItem.asObservable(),
                               didLoadACashAssets,
                               didChangeFiatAmount.asObservable())
                .throttle(RxTimeInterval.seconds(1), scheduler: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
                .withLatestFrom(stateTransformTrait.readOnlyState, resultSelector: latestFromBothValues())
                .compactMap { assetsInfo, buyCryptoState -> BuyCryptoState? in
                    let (fiatItemVM, cryptoItemVM, loadedAssetsInfo, fiatAmountOptional) = assetsInfo

                    guard let amount = fiatAmountOptional else { return nil }
                    let fiatAmount = Double(amount) ?? 0

                    switch buyCryptoState.state {
                    case let .checkingExchangePair(senderAsset, recipientAsset, _, paymentMethod):
                        if fiatItemVM.id == senderAsset.id, cryptoItemVM.id == recipientAsset.id {
                            return buyCryptoState.copy(newState: .checkingExchangePair(senderAsset: senderAsset,
                                                                                       recipientAsset: recipientAsset,
                                                                                       amount: fiatAmount,
                                                                                       paymentMethod: paymentMethod))
                        } else if let fiatAsset = loadedAssetsInfo.fiatAssets.first(where: { $0.id == fiatItemVM.id }),
                            let cryptoAsset = loadedAssetsInfo.cryptoAssets.first(where: { $0.id == cryptoItemVM.id }) {
                            return buyCryptoState.copy(newState: .checkingExchangePair(senderAsset: fiatAsset,
                                                                                       recipientAsset: cryptoAsset,
                                                                                       amount: fiatAmount,
                                                                                       paymentMethod: paymentMethod))
                        } else {
                            return nil
                        }

                    default: return nil
                    }
                }
                .do(afterNext: { buyCryptoState in
                    switch buyCryptoState.state {
                    case let .checkingExchangePair(senderAsset, recipientAsset, amount, paymentMethod):
                        checkingPairAction(senderAsset, recipientAsset, amount, paymentMethod)

                    default: return
                    }
            })

            fromCheckingExchangeToCheckingExchange
                .bind(to: stateTransformTrait._state)
                .disposed(by: stateTransformTrait.disposeBag)
        }

        private static func fromReadyToExchangeToCheckingExchangePair(
            stateTransformTrait: StateTransformTrait<BuyCryptoState>,
            didLoadACashAssets: Observable<AssetsInfo>,
            didSelectFiat: ControlEvent<BuyCryptoPresenter.AssetViewModel>,
            didSelectCrypto: ControlEvent<BuyCryptoPresenter.AssetViewModel>,
            didChangeFiatAmount: ControlEvent<String?>,
            checkingPairAction: @escaping (FiatAsset, CryptoAsset, Double, PaymentMethod) -> Void) {
            let fromACashAssetsLoadedToCheckingExchangePair = Observable
                .combineLatest(didSelectFiat.asObservable(),
                               didSelectCrypto.asObservable(),
                               didLoadACashAssets,
                               didChangeFiatAmount.asObservable())
                .throttle(RxTimeInterval.seconds(1), scheduler: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
                .withLatestFrom(stateTransformTrait.readOnlyState, resultSelector: latestFromBothValues())
                .compactMap { assetsInfo, buyCryptoState -> BuyCryptoState? in
                    let (fiatItemVM, cryptoItemVM, loadedAssetsInfo, fiatAmountOptional) = assetsInfo

                    guard let amount = fiatAmountOptional else { return nil }
                    let fiatAmount = Double(amount) ?? 0

                    switch buyCryptoState.state {
                    case let .readyForExchange(exchangeInfo, paymentMethod):
                        if fiatItemVM.id == exchangeInfo.senderAsset.id, cryptoItemVM.id == exchangeInfo.recipientAsset.id {
                            return buyCryptoState.copy(newState: .checkingExchangePair(senderAsset: exchangeInfo.senderAsset,
                                                                                       recipientAsset: exchangeInfo
                                                                                           .recipientAsset,
                                                                                       amount: fiatAmount,
                                                                                       paymentMethod: paymentMethod))
                        } else if let fiatAsset = loadedAssetsInfo.fiatAssets.first(where: { $0.id == fiatItemVM.id }),
                            let cryptoAsset = loadedAssetsInfo.cryptoAssets.first(where: { $0.id == cryptoItemVM.id }) {
                            return buyCryptoState.copy(newState: .checkingExchangePair(senderAsset: fiatAsset,
                                                                                       recipientAsset: cryptoAsset,
                                                                                       amount: fiatAmount,
                                                                                       paymentMethod: paymentMethod))
                        } else {
                            return nil
                        }

                    default: return nil
                    }
                }
                .do(afterNext: { buyCryptoState in
                    switch buyCryptoState.state {
                    case let .checkingExchangePair(senderAsset, recipientAsset, amount, paymentMethod):
                        checkingPairAction(senderAsset, recipientAsset, amount, paymentMethod)
                    default:
                        return
                    }
            })

            fromACashAssetsLoadedToCheckingExchangePair
                .bind(to: stateTransformTrait._state)
                .disposed(by: stateTransformTrait.disposeBag)
        }

        private static func fromReadyToExchangeToExchangeProcessing(
            stateTransformTrait: StateTransformTrait<BuyCryptoState>,
            didTapBuy: ControlEvent<Void>,
            didChangeFiatAmount: ControlEvent<String?>,
            processingEntryAction: @escaping (String, ExchangeInfo, PaymentMethod) -> Void) {
            let fromReadyToExchangeToExchangeProcessing = Observable
                .combineLatest(didTapBuy, didChangeFiatAmount.compactMap())
                .withLatestFrom(stateTransformTrait.readOnlyState, resultSelector: latestFromBothValues())
                .denestifyTuple()
                .compactMap { _, fiatAmount, buyCryptoState -> BuyCryptoState? in
                    switch buyCryptoState.state {
                    case let .readyForExchange(exchangeInfo, paymentMethod):
                        return buyCryptoState.copy(newState: .processingExchange(amount: fiatAmount, exchangeInfo: exchangeInfo, paymentMethod: paymentMethod))

                    default: return nil
                    }
                }.do(afterNext: { buyCryptoState in
                    switch buyCryptoState.state {
                    case let .processingExchange(amount, exchangeInfo, paymentMethod):
                        processingEntryAction(amount, exchangeInfo, paymentMethod)
                    default:
                        return
                    }
            })

            fromReadyToExchangeToExchangeProcessing
                .bind(to: stateTransformTrait._state)
                .disposed(by: stateTransformTrait.disposeBag)
        }

        private static func fromExchangeProcessingToExchangeInProgress(stateTransformTrait: StateTransformTrait<BuyCryptoState>,
                                                                       didProcessedExchange: Observable<URL>,
                                                                       openUrlEntryAction: @escaping (URL) -> Void) {
            let fromExchangeProcessingToExchangeInProgress = didProcessedExchange
                .withLatestFrom(stateTransformTrait.readOnlyState, resultSelector: latestFromBothValues())
                .compactMap { url, buyCryptoState -> BuyCryptoState? in
                    switch buyCryptoState.state {
                    case let .processingExchange(_, exchangeInfo, paymentMethod):
                        return buyCryptoState.copy(newState: .exchangeInProgress(url: url, exchangeInfo: exchangeInfo, paymentMethod: paymentMethod))
                    default: return nil
                    }
                }
                .do(afterNext: { buyCryptoState in
                    switch buyCryptoState.state {
                    case let .exchangeInProgress(url, _, _): openUrlEntryAction(url)
                    default: return
                    }
            })

            fromExchangeProcessingToExchangeInProgress
                .bind(to: stateTransformTrait._state)
                .disposed(by: stateTransformTrait.disposeBag)
        }

        private static func fromExchangeInProgressToReadyForExchange(stateTransformTrait: StateTransformTrait<BuyCryptoState>,
                                                                     didClosedWebView: Observable<Void>) {
            let fromExchangeInProgressToReadyForExchange = didClosedWebView
                .withLatestFrom(stateTransformTrait.readOnlyState, resultSelector: latestFromBothValues())
                .compactMap { _, buyCryptoState -> BuyCryptoState? in
                    switch buyCryptoState.state {
                    case let .exchangeInProgress(_, exchangeInfo, paymentMethod):
                        return buyCryptoState.copy(newState: .readyForExchange(exchangeInfo, paymentMethod))
                    default: return nil
                    }
                }

            fromExchangeInProgressToReadyForExchange
                .bind(to: stateTransformTrait._state)
                .disposed(by: stateTransformTrait.disposeBag)
        }
    }
}
