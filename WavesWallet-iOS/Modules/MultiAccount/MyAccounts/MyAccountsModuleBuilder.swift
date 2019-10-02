//
//  MyAccountsModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Лера on 10/1/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import Extensions

struct MyAccountsModuleBuilder: ModuleBuilder {
    
    func build(input: Void) -> UIViewController {
        let vc = StoryboardScene.MultiAccount.myAccountsViewController.instantiate()
        vc.system = MyAccountsSystem()
        return vc
    }
}
