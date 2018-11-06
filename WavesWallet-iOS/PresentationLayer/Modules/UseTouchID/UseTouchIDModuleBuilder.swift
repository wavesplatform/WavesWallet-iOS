//
//  UseTouchIDModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 27/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct UseTouchIDModuleBuilder: ModuleBuilderOutput {

    struct Input: UseTouchIDModuleInput {
        var passcode: String
        var wallet: DomainLayer.DTO.Wallet
    }

    var output: UseTouchIDModuleOutput

    func build(input: Input) -> UIViewController {

        let vc = StoryboardScene.UseTouchID.useTouchIDViewController.instantiate()
        vc.moduleOutput = output
        vc.input = input
        return vc
    }
}
