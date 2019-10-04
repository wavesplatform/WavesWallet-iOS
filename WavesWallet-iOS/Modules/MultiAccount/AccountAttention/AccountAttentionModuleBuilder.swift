//
//  AccountAttentionModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Лера on 10/4/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import Extensions


struct AccountAttentionModuleBuilder: ModuleBuilderOutput {
  
    var output: AccountAttentionViewControllerDelegate
    
    func build(input: Void) -> UIViewController {
        
        let vc = StoryboardScene.MultiAccount.accountAttentionViewController.instantiate()
        vc.delegate = output
        return vc
    }
}
