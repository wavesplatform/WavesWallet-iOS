//
//  EditAccountNameModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Mac on 02/11/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct EditAccountNameModuleBuilder: ModuleBuilderOutput {
    
    struct Input: EditAccountNameModuleInput {}
    
    var output: EditAccountNameModuleOutput
    
    func build(input: Input) -> UIViewController {
        let vc = StoryboardScene.EditAccountName.editAccountNameViewController.instantiate()
        return vc
    }
    
}
