//
//  NewAccountPasscodeBuilder.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 19/09/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import UIKit

struct PasscodeModuleBuilder: ModuleBuilderOutput {
    struct Input: PasscodeModuleInput {
        var kind: PasscodeTypes.DTO.Kind
        var hasBackButton: Bool
    }

    var output: PasscodeModuleOutput

    func build(input: PasscodeModuleBuilder.Input) -> UIViewController {
        let vc = StoryboardScene.Passcode.passcodeViewController.instantiate()

        var presenter: PasscodePresenterProtocol!

        switch input.kind {
        case .registration:
            presenter = PasscodeRegistationPresenter()

        case .logIn:
            presenter = PasscodeLogInPresenter()

        case .verifyAccess:
            presenter = PasscodeVerifyAccessPresenter()

        case .changePasscodeByPassword:
            presenter = PasscodeChangePasscodeByPasswordPresenter()

        case .changePassword:
            presenter = PasscodeChangePasswordPresenter()

        case .changePasscode:
            presenter = PasscodePresenter()

        case .setEnableBiometric:
            presenter = PasscodeEnableBiometricPresenter()
        }

        presenter.interactor = PasscodeInteractor(authorizationInteractor: UseCasesFactory.instance.authorization)
        presenter.moduleOutput = output
        presenter.input = input
        vc.presenter = presenter

        return vc
    }
}
