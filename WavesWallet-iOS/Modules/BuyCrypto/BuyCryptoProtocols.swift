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
}

extension BuyCryptoInteractor {
    struct ApiResponse {
        @PublishObservable var didLoadACashAssets: Observable<BuyCryptoInteractor.AssetsInfo>
        @PublishObservable var aCashAssetsLoadingError: Observable<Error>
    }
}

extension BuyCryptoInteractor {
    struct AssetsInfo {
        let fiatAssets: [FiatAsset]
        let cryptoAssets: [CryptoAsset] //[Asset]
    }
    
    struct CryptoAsset {
        let name: String
        let id: String
        let decimals: Int32
        
        let assetInfo: WalletEnvironment.AssetInfo // Asset
    }
    
    struct FiatAsset {
        let name: String
        let id: String
        let decimals: Int32
        
        let assetInfo: WalletEnvironment.AssetInfo
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
}

struct BuyCryptoPresenterOutput {
    /// Драйвер отображения контента экрана
    let contentVisible: Driver<Bool>
    
    /// Драйвер отображения индикатора загрузки
    let isLoadingIndicator: Driver<Bool>
    
    /// Сигнал отображения ошибки
    let error: Signal<String>
    
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
    
    ///
    let detailsInfo: Driver<String>
}

struct BuyCryptoViewOutput {
    
    /// Выбранный элемент валюты из реального мира (евро, доллар и тд)
    let didSelectFiatItem: ControlEvent<BuyCryptoPresenter.AssetViewModel>
    
    /// Выбранный элемент крипты (usdn, btc и тд)
    let didSelectCryptoItem: ControlEvent<BuyCryptoPresenter.AssetViewModel>
    
    /// Сигнал изменения поля ввода количества валюты реального мира
    let didChangeFiatAmount: ControlEvent<String>
    
    /// Нажатие на кнопку купить
    let didTapBuy: ControlEvent<Void>
    
    /// Сигнал загруженной вью для начала загрузки (внутри interactor для него выполняется оператор take(1))
    let viewWillAppear: ControlEvent<Void>
    
    /// Нажатие на кнопку "Повторить" на экране ошибки
    let didTapRetry: ControlEvent<Void>
}
