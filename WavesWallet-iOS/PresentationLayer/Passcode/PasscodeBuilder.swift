//
//  NewAccountPasscodeBuilder.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 19/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct PasscodeModuleBuilder: ModuleBuilderOutput {

    struct Input: PasscodeInput {
        var kind: PasscodeTypes.DTO.Kind
    }

    var output: PasscodeOutput

    func build(input: PasscodeModuleBuilder.Input) -> UIViewController {

        let presenter = PasscodePresenter()
        let vc = StoryboardScene.NewAccount.newAccountPasscodeViewController.instantiate()
        presenter.interactor = PasscodeInteractor()
        presenter.moduleOutput = output
        presenter.input = input
        vc.presenter = presenter

        return vc
    }
}
