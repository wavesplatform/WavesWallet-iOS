//
//  NewAccountPasscodeBuilder.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 19/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct PasscodeModuleBuilder: ModuleBuilderOutput {

    struct Input: PasscodeModuleInput {
        var kind: PasscodeTypes.DTO.Kind
        var hasBackButton: Bool
    }

    var output: PasscodeModuleOutput

    func build(input: PasscodeModuleBuilder.Input) -> UIViewController {

        let presenter = PasscodePresenter()
        let vc = StoryboardScene.Passcode.passcodeViewController.instantiate()
        presenter.interactor = PasscodeInteractor()
        presenter.moduleOutput = output
        presenter.input = input
        vc.presenter = presenter

        return vc
    }
}
