//
//  StartLeasingModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/29/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct StartLeasingModuleBuilder: ModuleBuilder {
    
    func build(input: Void) -> UIViewController {
        
        let vc = StoryboardScene.StartLeasing.startLeasingViewController.instantiate()
        return vc
    }
}
