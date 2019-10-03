//
//  EditAccountNameModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Лера on 10/3/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import Extensions
import DomainLayer

protocol NewEditAccountNameModuleBuilderOutput: AnyObject {
    func newEditAccountDidChangeName(newName: String)
}

struct NewEditAccountNameModuleBuilder: ModuleBuilderOutput {
    
    var output: NewEditAccountNameModuleBuilderOutput
    
    func build(input: DomainLayer.DTO.Wallet) -> UIViewController {
        
        let vc = StoryboardScene.MultiAccount.newEditAccountNameViewController.instantiate()
        vc.wallet = input
        vc.delegate = output
        return vc
    }
}
