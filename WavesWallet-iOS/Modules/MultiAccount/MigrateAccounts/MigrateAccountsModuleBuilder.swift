//
//  MigrateAccountModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Лера on 10/1/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import Extensions

struct MigrateAccountsModuleBuilder: ModuleBuilder {
    
    func build(input: Void) -> UIViewController {
        
        let vc = StoryboardScene.MultiAccount.migrateAccountsViewController.instantiate()
        vc.system = MigrateAccountsSystem()
        return vc
    }
}
