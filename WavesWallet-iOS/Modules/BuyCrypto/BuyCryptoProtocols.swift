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
    case aCashAssetsLoaded([BuyCryptoInteractor.Asset])
}

extension BuyCryptoInteractor {
    struct ApiResponse {
        @PublishObservable var didLoadACashAssets: Observable<[BuyCryptoInteractor.Asset]>
        @PublishObservable var aCashAssetsLoadingError: Observable<Error>
    }
}

// MARK: - ViewController

protocol BuyCryptoViewControllable {}

// MARK: - Presenter

protocol BuyCryptoPresentable {}

// MARK: Outputs

struct BuyCryptoInteractorOutput {
    let readOnlyState: Observable<BuyCryptoState>
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
}

struct BuyCryptoViewOutput {
    
    /// Сигнал загруженной вью для начала загрузки (внутри interactor для него выполняется оператор take(1))
    let viewWillAppear: ControlEvent<Void>
    
    /// Нажатие на кнопку "Повторить" на экране ошибки
    let didTapRetry: ControlEvent<Void>
}
