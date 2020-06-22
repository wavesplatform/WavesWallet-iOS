//
//  EditAccountNameModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Mac on 02/11/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit
import DomainLayer
import Extensions

struct EditAccountNameModuleBuilder: ModuleBuilderOutput {
    
    struct Input: EditAccountNameModuleInput {
        var wallet: Wallet
    }
    
    var output: EditAccountNameModuleOutput
    
    func build(input: Input) -> UIViewController {
        let vc = StoryboardScene.EditAccountName.editAccountNameViewController.instantiate()
        vc.wallet = input.wallet
        return vc
    }
    
}
