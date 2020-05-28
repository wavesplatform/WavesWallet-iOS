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

protocol BuyCryptoBuildable {
    /// Сборка модуля покупки крипты с помощью валют с карты (евро, доллар и тд)
    func build() -> BuyCryptoViewController
}

// MARK: - Interactor

protocol BuyCryptoInteractable {}

enum BuyCryptoState {
    /// Состояние загрузки экрана
    case isLoading
    
    /// Состояние ошибки (отображение экрана ошибки)
    case loadingError(String)
    
    /// Состояние загруженного экрана (загружены
    case aCashAssetsLoaded(BuyCryptoInteractor.AssetsInfo)
    
    /// Состояние проверки обменной пары
    case checkingExchangePair(senderAsset: String, recipientAsset: String)
    
    /// Состояние ошибки проверки обменной пары (отображать ошибку)
    case checkingExchangePairError(error: Error, senderAsset: String, recipientAsset: String)
    
    ///
    case readyForExchange(BuyCryptoInteractor.ExchangeInfo)
    
    ///
    case exchangeInProgress
}

extension BuyCryptoInteractor {
    struct ApiResponse {
        @PublishObservable var didLoadACashAssets: Observable<BuyCryptoInteractor.AssetsInfo>
        @PublishObservable var aCashAssetsLoadingError: Observable<Error>
        
        @PublishObservable var didCheckedExchangePair: Observable<BuyCryptoInteractor.ExchangeInfo>
        @PublishObservable var checkingExchangePairError: Observable<Error>
        
        @PublishObservable var didCalculateExchangeCost: Observable<Void>
        @PublishObservable var calculationExchangeCostError: Observable<Error>
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
        case lessMin(min: Decimal)
        case moreMax(max: Decimal)
        
        var errorDescription: String? {
            switch self {
            case .isNaN: return "isNaN"
            case .lessMin(let min): return "lessMin \(min)"
            case .moreMax(let max): return "moreMax \(max)"
            }
        }
        
        var localizedDescription: String {
            switch self {
            case .isNaN: return "isNaN"
            case .lessMin(let min): return "lessMin \(min)"
            case .moreMax(let max): return "moreMax \(max)"
            }
        }
    }
}

// MARK: - ViewController

protocol BuyCryptoViewControllable {}

// MARK: - Presenter

protocol BuyCryptoPresentable {}

// MARK: Outputs

struct BuyCryptoInteractorOutput {
    let readOnlyState: Observable<BuyCryptoState>

    /// Выбранный элемент валюты из реального мира (евро, доллар и тд)
    let didSelectFiatItem: ControlEvent<BuyCryptoPresenter.AssetViewModel>

    /// Выбранный элемент крипты (usdn, btc и тд)
    let didSelectCryptoItem: ControlEvent<BuyCryptoPresenter.AssetViewModel>
    
    /// Сигнал изменения поля ввода количества валюты реального мира (необходимо чтобы в состоянии availableExchange посчитать сколько пользователь получит)
    let didChangeFiatAmount: ControlEvent<String?>
    
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
    let buyButtonModel: Driver<TitledBool>
    
    /// драйвер с информацией об обмене валюты на крипту
    let detailsInfo: Driver<BuyCryptoPresenter.ExchangeMessage>
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
    
    /// Сигнал загруженной вью для начала загрузки (внутри interactor для него выполняется оператор take(1))
    let viewWillAppear: ControlEvent<Void>
    
    /// Нажатие на кнопку "Повторить" на экране ошибки
    let didTapRetry: ControlEvent<Void>
}
