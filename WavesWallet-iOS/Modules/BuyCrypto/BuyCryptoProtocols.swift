// 
//  BuyCryptoProtocols.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 13.05.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import RxSwift

// MARK: - Builder

protocol BuyCryptoBuildable {
    /// <#Description#>
    func build() -> BuyCryptoViewController
}

// MARK: - Interactor

protocol BuyCryptoInteractable {}

// MARK: - ViewController

protocol BuyCryptoViewControllable {}

// MARK: - Presenter

protocol BuyCryptoPresentable {}

// MARK: Outputs

struct BuyCryptoInteractorOutput {}

struct BuyCryptoPresenterOutput {}

struct BuyCryptoViewOutput {}
