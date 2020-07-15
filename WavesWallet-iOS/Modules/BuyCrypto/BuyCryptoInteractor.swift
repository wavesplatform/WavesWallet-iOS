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
         weOAuthRepository: WEOAuthRepositoryProtocol,
         selectedAsset: Asset?) {
        self.presenter = presenter
        
        let buyCryptoState = BuyCryptoState(selectedAsset: selectedAsset, state: .isLoading)
        let _state = BehaviorRelay<BuyCryptoState>(value: buyCryptoState)
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

    private func checkingExchangePair(senderAsset: FiatAsset, recipientAsset: CryptoAsset, amount: Double,
                                      paymentSystem: PaymentMethod) {
        networker
            .getExchangeRate(senderAsset: senderAsset, recipientAsset: recipientAsset, amount: amount, paymentSystem: paymentSystem) { [weak self] result in
                switch result {
                case let .success(exchangeInfo): self?.apiResponse.$didCheckedExchangePair.accept(exchangeInfo)
                case let .failure(error): self?.apiResponse.$checkingExchangePairError.accept(error)
                }
            }
    }

    private func performDepositeProcessing(amount: String, exchangeInfo: ExchangeInfo, paymentSystem: PaymentMethod) {
        let amount = Double(amount) ?? 0

        networker.deposite(senderAsset: exchangeInfo.senderAsset,
                           recipientAsset: exchangeInfo.recipientAsset,
                           exchangeAddress: exchangeInfo.exchangeAddress,
                           amount: amount,
                           paymentSystem: paymentSystem,
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

        input.didTapURL
            .filteredByState(stateTransformTrait.readOnlyState) { buyCryptoState -> Bool in
                switch buyCryptoState.state {
                case .readyForExchange, .aCashAssetsLoaded, .checkingExchangePair, .checkingExchangePairError:
                    return true
                default: return false
                }
            }
            .subscribe(onNext: { [weak self] url in self?.listener?.openUrl(url, delegate: nil) })
            .disposed(by: disposeBag)

        let stateTransformActions = StateTransformActions(
            initialLoadingEntryAction: { [weak self] in
                self?.performInitialLoading()
            },
            checkingExchangePairEntryAction: { [weak self] in
                self?.checkingExchangePair(senderAsset: $0, recipientAsset: $1, amount: $2, paymentSystem: $3)
            },
            processingEntryAction: { [weak self] in
                self?.performDepositeProcessing(amount: $0, exchangeInfo: $1, paymentSystem: $2)
            },
            openUrlEntryAction: { [weak self] url in
                DispatchQueue.main.async { [weak self] in
                    self?.listener?.openUrl(url, delegate: self)
                }
            })

        StateTransform.performTransformations(stateTransformTrait: stateTransformTrait,
                                              viewOutput: input,
                                              apiResponse: apiResponse,
                                              internalActions: internalActions,
                                              stateTransformActions: stateTransformActions)

        // костылик, надо будет подумать как это нормально сделать
        // когда происходит прокручивание ассета число сбрасывать или оставлять это и делать пересчет?
        let validationError = Helper.makeValidationFiatAmount(readOnlyState: stateTransformTrait.readOnlyState,
                                                              didChangeFiatAmount: input.didChangeFiatAmount)
        
        // didSelectFiatItem, didSelectCryptoItem, didTapAdCashPaymentMethod проходят транзитом через интерактор
        // в presenter необходимо изменять title(ы) на лейблах и кнопке
        return BuyCryptoInteractorOutput(readOnlyState: stateTransformTrait.readOnlyState,
                                         didSelectFiatItem: input.didSelectFiatItem,
                                         didSelectCryptoItem: input.didSelectCryptoItem,
                                         didChangeFiatAmount: input.didChangeFiatAmount,
                                         didTapAdCashPaymentMethod: input.didTapAdCashPaymentMethod,
                                         didSelectPaymentMethod: input.didSelectPaymentMethod,
                                         validationError: validationError)
    }
}

extension BuyCryptoInteractor: BrowserViewControllerDelegate {
    func browserViewRedirect(_ browserVC: BrowserViewController, url: URL) {
        let link = url.absoluteStringByTrimmingQuery() ?? ""

        if link.contains(DomainLayerConstants.URL.fiatDepositSuccess) {
            internalActions.$exchangeSuccessful.accept(Void())
            browserVC.dismiss(animated: true)
        } else if link.contains(DomainLayerConstants.URL.fiatDepositFail) {
            internalActions.$exchangeFailed.accept(Void())
            browserVC.dismiss(animated: true)
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
                .map { optionalFiatAmount, buyCryptoState -> Error? in
                    switch buyCryptoState.state {
                    case let .readyForExchange(exchangeInfo, _):
                        guard let fiatAmount = optionalFiatAmount, !fiatAmount.isEmpty else { return nil }

                        guard let fiatAmountNumber = Decimal(string: fiatAmount) else {
                            return FiatAmountValidationError.isNaN
                        }

                        if fiatAmountNumber > exchangeInfo.maxLimit {
                            return FiatAmountValidationError.moreMax(max: exchangeInfo.maxLimit,
                                                                     decimals: Int(exchangeInfo.senderAsset.decimals),
                                                                     name: exchangeInfo.senderAsset.name)
                        } else if fiatAmountNumber < exchangeInfo.minLimit {
                            return FiatAmountValidationError.lessMin(min: exchangeInfo.minLimit,
                                                                     decimals: Int(exchangeInfo.senderAsset.decimals),
                                                                     name: exchangeInfo.senderAsset.name)
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
