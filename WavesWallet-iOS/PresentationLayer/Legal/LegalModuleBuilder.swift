//
//  CheckboxModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Mac on 10/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct LegalModuleBuilder: ModuleBuilderOutput {
    
    var output: LegalModuleOutput
    
    func build(input: LegalModuleInput) -> UIViewController {
        
        let vc = StoryboardScene.Legal.legalViewController.instantiate()
        vc.transitioningDelegate = vc
        vc.modalPresentationStyle = .custom
 
        vc.output = output
        
        return vc
    }
}
