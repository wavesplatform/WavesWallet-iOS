//
//  ModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 26/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct AccountPasswordModuleBuilder: ModuleBuilderOutput {

    struct Input: AccountPasswordModuleInput {
        var wallet: DomainLayer.DTO.Wallet
    }

    var output: AccountPasswordModuleOutput

    func build(input: AccountPasswordModuleBuilder.Input) -> UIViewController {

        let vc = StoryboardScene.AccountPassword.accountPasswordViewController.instantiate()
        let presenter = AccountPasswordPresenter()
        presenter.interactor = AccountPasswordInteractor()
        presenter.moduleOutput = output
        presenter.input = input
        vc.presenter = presenter
        return vc
    }
}
