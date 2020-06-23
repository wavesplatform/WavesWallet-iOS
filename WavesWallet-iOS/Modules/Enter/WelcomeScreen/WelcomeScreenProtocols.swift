// 
//  WelcomeScreenProtocols.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 19.06.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import RxCocoa
import RxSwift

// MARK: - Builder

protocol WelcomeScreenBuildable {
    /// <#Description#>
    func build() -> WelcomeScreenViewController
}

// MARK: - Interactor

protocol WelcomeScreenInteractable {}

// MARK: - ViewController

protocol WelcomeScreenViewControllable {}

// MARK: - Presenter

protocol WelcomeScreenPresentable {}

// MARK: Outputs

struct WelcomeScreenInteractorOutput {}

struct WelcomeScreenPresenterOutput {}

struct WelcomeScreenViewOutput {
    let viewWillAppear: Observable<Void>
}
