//
//  DexCreateOrderInfoModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 14.11.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import Extensions

protocol DexCreateOrderInfoModuleBuilderOutput: AnyObject {

    func dexCreateOrderInfoDidTapClose()
}

struct DexCreateOrderInfoModuleBuilder: ModuleBuilderOutput {
    
    var output: DexCreateOrderInfoModuleBuilderOutput
    
    func build(input: Void) -> UIViewController {
        let vc = StoryboardScene.Dex.dexCreateOrderInfoViewController.instantiate()
        vc.output = output
        return vc
    }
}
