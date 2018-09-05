//
//  DexChartModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/16/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct DexChartModuleBuilder: ModuleBuilder {
    
    func build(input: Void) -> UIViewController {
        let vc = StoryboardScene.Dex.dexChartViewController.instantiate()
        return vc
    }
}
