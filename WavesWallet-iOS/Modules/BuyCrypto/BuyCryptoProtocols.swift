// 
//  BuyCryptoProtocols.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 13.05.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import AppTools
import DomainLayer
import RxCocoa
import RxSwift

// MARK: - Builder

protocol BuyCryptoBuildable: AnyObject {
    /// Сборка модуля покупки крипты с помощью валют с карты (евро, доллар и тд)
    func build(with listener: BuyCryptoListener, selectedAsset: Asset?) -> BuyCryptoViewController
}

// MARK: - Listener

protocol BuyCryptoListener: AnyObject {
    func openUrl(_ url: URL, delegate: BrowserViewControllerDelegate?)
}

// MARK: - Interactor

protocol BuyCryptoInteractable: AnyObject {}

struct BuyCryptoState {
    let selectedAsset: Asset?
    let state: State
    
    enum State {
        typealias FiatAsset = BuyCryptoInteractor.FiatAsset
        typealias CryptoAsset = BuyCryptoInteractor.CryptoAsset
        
        /// Состояние загрузки экрана
        case isLoading
        
        /// Состояние ошибки (отображение экрана ошибки)
        case loadingError(Error)
        
        /// Состояние загруженного экрана (загружены
        case aCashAssetsLoaded(BuyCryptoInteractor.AssetsInfo)
        
        /// Состояние проверки обменной пары
        case checkingExchangePair(senderAsset: FiatAsset, recipientAsset: CryptoAsset, amount: Double, paymentMethod: PaymentMethod)
        
        /// Состояние ошибки проверки обменной пары (отображать ошибку)
        case checkingExchangePairError(error: Error, senderAsset: FiatAsset, recipientAsset: CryptoAsset, amount: Double)
        
        /// Состояние, когда обмен фиатной валюты в крипто валюту готов
        case readyForExchange(BuyCryptoInteractor.ExchangeInfo)
        
        /// Состояние, когда обмен валюты запущен
        case processingExchange(amount: String, exchangeInfo: BuyCryptoInteractor.ExchangeInfo, paymentMethod: PaymentMethod)
        
        /// Ошибка начала обмена
        case exchangeProcessingError(Error, amount: String, exchangeInfo: BuyCryptoInteractor.ExchangeInfo)
        
        /// Обмен в процессе (обмен происходит по урлу)
        case exchangeInProgress(url: URL, exchangeInfo: BuyCryptoInteractor.ExchangeInfo, paymentMethod: PaymentMethod)
        
        ///
        case exchangeSuccessful(BuyCryptoInteractor.ExchangeInfo)
        
        ///
        case exchangeFailed(BuyCryptoInteractor.ExchangeInfo)
    }
}

extension BuyCryptoState {
    func copy(newState: State) -> BuyCryptoState {
        BuyCryptoState(selectedAsset: selectedAsset, state: newState)
    }
}

// MARK: - ApiResponse

extension BuyCryptoInteractor {
    struct ApiResponse {
        @PublishObservable var didLoadACashAssets: Observable<BuyCryptoInteractor.AssetsInfo>
        @PublishObservable var aCashAssetsLoadingError: Observable<Error>
        
        @PublishObservable var didCheckedExchangePair: Observable<BuyCryptoInteractor.ExchangeInfo>
        @PublishObservable var checkingExchangePairError: Observable<Error>
        
        @PublishObservable var didProcessedExchange: Observable<URL>
        @PublishObservable var processingExchangeError: Observable<Error>
    }
}

// MARK: - InternalActions

extension BuyCryptoInteractor {
    struct InternalActions {
        @PublishObservable var didClosedWebView: Observable<Void>
        @PublishObservable var exchangeSuccessful: Observable<Void>
        @PublishObservable var exchangeFailed: Observable<Void>
    }
}

extension BuyCryptoInteractor {
    struct StateTransformActions {
        let initialLoadingEntryAction: VoidClosure
        let checkingExchangePairEntryAction: (FiatAsset, CryptoAsset, Double, PaymentMethod) -> Void
        let processingEntryAction: (String, ExchangeInfo, PaymentMethod) -> Void
        let openUrlEntryAction: (URL) -> Void
    }
}

extension BuyCryptoInteractor {
    struct AssetsInfo {
        let fiatAssets: [FiatAsset]
        let cryptoAssets: [CryptoAsset]
    }
    
    struct CryptoAsset {
        let name: String
        let id: String
        let decimals: Int32
        
        let assetInfo: WalletEnvironment.AssetInfo?
    }
    
    struct FiatAsset {
        let name: String
        let id: String
        let decimals: Int32
        
        let assetInfo: WalletEnvironment.AssetInfo?
    }
}

extension BuyCryptoInteractor {
    enum FiatAmountValidationError: LocalizedError {
        case isNaN
        case lessMin(min: Decimal, decimals: Int, name: String)
        case moreMax(max: Decimal, decimals: Int, name: String)
    }
}

// MARK: - ViewController

protocol BuyCryptoViewControllable: AnyObject {}

// MARK: - Presenter

protocol BuyCryptoPresentable: AnyObject {}

// MARK: Outputs

struct BuyCryptoInteractorOutput {
    let readOnlyState: Observable<BuyCryptoState>

    /// Выбранный элемент валюты из реального мира (евро, доллар и тд)
    let didSelectFiatItem: ControlEvent<BuyCryptoPresenter.AssetViewModel>

    /// Выбранный элемент крипты (usdn, btc и тд)
    let didSelectCryptoItem: ControlEvent<BuyCryptoPresenter.AssetViewModel>
    
    /// Сигнал изменения поля ввода количества валюты реального мира (необходимо чтобы в состоянии availableExchange посчитать сколько пользователь получит)
    let didChangeFiatAmount: ControlEvent<String?>
    
    /// Тап на открытие модалки с выбором способов оплаты
    let didTapAdCashPaymentMethod: ControlEvent<Void>
    
    /// Выбранный способ оплаты
    let didSelectPaymentMethod: ControlEvent<PaymentMethod>
    
    /// Сигнал ошибки валидации
    let validationError: Signal<Error?>
}

struct BuyCryptoPresenterOutput {
    /// Драйвер отображения контента экрана
    let contentVisible: Driver<Bool>
    
    /// Драйвер отображения индикатора загрузки
    let isLoadingIndicator: Driver<Bool>
    
    /// Сигнал отображения фатальной ошибки
    let initialError: Signal<String>
    
    /// Сигнал отображения не фатальных ошибок (в снекбаре)
    let showSnackBarError: Signal<String>
    
    /// Сигнал отображения ошибки валидации
    let validationError: Signal<String?>
    
    /// Драйвер с фиатным тайтлом (он изменяется в зависимости от выбранного фиатного ассета)
    let fiatTitle: Driver<String>
    
    /// Драйвер с фиатными ассетами
    let fiatItems: Driver<[BuyCryptoPresenter.AssetViewModel]>
    
    /// Драйвер с крипто тайтлом (он изменяется в зависимости от выбранного крипто ассета)
    let cryptoTitle: Driver<String>
    
    /// Драйвер с крипто ассетами
    let cryptoItems: Driver<[BuyCryptoPresenter.AssetViewModel]>
    
    /// Драйвер с тайтлом и стейтом кнопки
    let buyButtonModel: Driver<BlueButton.Model>
    
    /// драйвер с информацией об обмене валюты на крипту
    let detailsInfo: Driver<NSAttributedString>
    
    let showPaymentMethods: Signal<TitledModel<[BuyCryptoPresenter.PaymentMethodVM]>>
}

struct BuyCryptoViewOutput {
    
    /// Выбранный элемент валюты из реального мира (евро, доллар и тд)
    let didSelectFiatItem: ControlEvent<BuyCryptoPresenter.AssetViewModel>
    
    /// Выбранный элемент крипты (usdn, btc и тд)
    let didSelectCryptoItem: ControlEvent<BuyCryptoPresenter.AssetViewModel>
    
    /// Сигнал изменения поля ввода количества валюты реального мира
    let didChangeFiatAmount: ControlEvent<String?>
    
    /// Нажатие на кнопку купить
    let didTapBuy: ControlEvent<Void>
    
    /// Нажатие на выбор способа оплаты
    let didTapAdCashPaymentMethod: ControlEvent<Void>
    
    /// Событие выбранного способа оплаты
    let didSelectPaymentMethod: ControlEvent<PaymentMethod>
    
    /// Сигнал загруженной вью для начала загрузки (внутри interactor для него выполняется оператор take(1))
    let viewWillAppear: ControlEvent<Void>
    
    /// Нажатие на кнопку "Повторить" на экране ошибки
    let didTapRetry: ControlEvent<Void>
    
    /// Нажатие на ссылку в текст вью
    let didTapURL: ControlEvent<URL>
}
