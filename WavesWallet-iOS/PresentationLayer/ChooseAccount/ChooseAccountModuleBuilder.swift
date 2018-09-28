//
//  ChooseAccountModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 28/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct ChooseAccountModuleBuilder: ModuleBuilderOutput {

    struct Input: ChooseAccountModuleInput {
    }

    var output: ChooseAccountModuleOutput

    func build(input: ChooseAccountModuleBuilder.Input) -> UIViewController {

        let presenter = ChooseAccountPresenter()
        let vc = StoryboardScene.ChooseAccount.chooseAccountViewController.instantiate()
        presenter.interactor = ChooseAccountInteractor()
        presenter.moduleOutput = output
        presenter.input = input
        vc.presenter = presenter

        return vc
    }
}
