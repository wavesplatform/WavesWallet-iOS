//
//  MyOrdersModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 20.12.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import Extensions

struct MyOrdersModuleBuilder: ModuleBuilder {
    
    func build(input: Void) -> UIViewController {
        
        let vc = StoryboardScene.Dex.myOrdersViewController.instantiate()
        vc.system = MyOrdersSystem()
        return vc
    }
}
