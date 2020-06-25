// 
//  WelcomeScreenProtocols.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 19.06.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import AppTools
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

struct WelcomeScreenInteractorOutput {
    let viewWillAppear: ControlEvent<Void>
}

struct WelcomeScreenPresenterOutput {
    let viewModel: Driver<[WelcomeScreenViewModel]>
}

struct WelcomeScreenViewOutput {
    let viewWillAppear: ControlEvent<Void>
    
    let didTapUrl: ControlEvent<URL>
}

enum WelcomeScreenViewModel {
    case hello
    case easyRefill
    case invesmentInfo
    case termOfConditions
}

extension WelcomeScreenViewModel {
    var title: String {
        switch self {
        case .hello: return Localizable.Waves.Welcomescreen.welcomeTitle
        case .easyRefill: return Localizable.Waves.Welcomescreen.simpleWithdrawalTitle
        case .invesmentInfo: return Localizable.Waves.Welcomescreen.investmentsTitle
        case .termOfConditions: return Localizable.Waves.Welcomescreen.termOfConditions
        }
    }
    
    var details: String {
        switch self {
        case .hello: return Localizable.Waves.Welcomescreen.welcomeDetails
        case .easyRefill: return Localizable.Waves.Welcomescreen.simpleWithdrawalDetails
        case .invesmentInfo: return Localizable.Waves.Welcomescreen.investmentsDetails
        case .termOfConditions: return Localizable.Waves.Welcomescreen.allYourWavesAccountDataIsEncrypted
        }
    }
    
    var privacyPolicyText: TitledModel<String> {
        TitledModel<String>(title: Localizable.Waves.Welcomescreen.iHaveReadPrivacy,
                            model: Localizable.Waves.Welcomescreen.Ihavereadprivacy.linkWords)
    }
    
    var privacyPolicyTextLink: URL? {
        URL(string: UIGlobalConstants.URL.termsOfUse)
    }
    
    var termOfConditionsText: TitledModel<String> {
        TitledModel<String>(title: Localizable.Waves.Welcomescreen.iHaveReadTerms,
                            model: Localizable.Waves.Welcomescreen.Ihavereadterms.linkWords)
    }
    
    var termOfConditionsTextLink: URL? {
        URL(string: UIGlobalConstants.URL.termsOfConditions)
    }
}
