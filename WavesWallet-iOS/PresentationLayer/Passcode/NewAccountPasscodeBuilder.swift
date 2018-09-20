//
//  NewAccountPasscodeBuilder.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 19/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct PasscodeModuleBuilder: ModuleBuilderOutput {

    struct Input: NewAccountPasscodeInput {
        var kind: NewAccountPasscodeTypes.DTO.Kind
    }

    var output: NewAccountPasscodeOutput

    func build(input: PasscodeModuleBuilder.Input) -> UIViewController {

        let presenter = NewAccountPasscodePresenter()
        let vc = StoryboardScene.NewAccount.newAccountPasscodeViewController.instantiate()
        presenter.interactor = NewAccountPasscodeInteractor()
        presenter.moduleOutput = output
        presenter.input = input
        vc.presenter = presenter

        return vc
    }
}
