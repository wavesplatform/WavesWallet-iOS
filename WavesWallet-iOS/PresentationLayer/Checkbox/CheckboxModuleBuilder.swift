//
//  CheckboxModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Mac on 10/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct CheckboxModuleBuilder: ModuleBuilderOutput {
    
    var output: CheckboxModuleOutput
    
    func build(input: CheckboxModuleInput) -> UIViewController {
        
        let vc = StoryboardScene.Checkbox.checkboxViewController.instantiate()
        vc.input = input
        
        return vc
    }
}
