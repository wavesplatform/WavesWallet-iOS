//
//  ProfileModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 04/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct ProfileModuleBuilder: ModuleBuilderOutput {

    var output: ProfileModuleOutput

    func build(input: Void) -> UIViewController {

        let vc = StoryboardScene.Profile.profileViewController.instantiate()
        let presenter = ProfilePresenter()
        presenter.moduleOutput = output
        vc.presenter = presenter

        return vc
    }
}
