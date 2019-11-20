//
//  CreateAliasModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 29/10/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit
import Extensions

struct CreateAliasModuleBuilder: ModuleBuilderOutput {

    var output: CreateAliasModuleOutput

    func build(input: Void) -> UIViewController {

        let vc = StoryboardScene.Profile.createAliasViewController.instantiate()
        let presenter = CreateAliasPresenter()        
        presenter.moduleOutput = output
        vc.presenter = presenter

        return vc
    }
}
