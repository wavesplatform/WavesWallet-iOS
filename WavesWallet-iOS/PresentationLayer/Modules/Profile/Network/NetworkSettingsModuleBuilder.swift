//
//  NetworkSettingsModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 22/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct NetworkSettingsModuleBuilder: ModuleBuilderOutput {

    struct Input: NetworkSettingsModuleInput {
        var wallet: DomainLayer.DTO.Wallet
    }

    var output: NetworkSettingsModuleOutput

    func build(input: Input) -> UIViewController {

        let presenter = NetworkSettingsPresenter(input: input)
        let vc = StoryboardScene.Profile.networkSettingsViewController.instantiate()
        presenter.moduleOutput = output
        vc.presenter = presenter

        return vc
    }
}
