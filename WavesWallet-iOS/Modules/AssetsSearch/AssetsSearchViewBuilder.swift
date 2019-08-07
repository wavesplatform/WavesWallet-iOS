//
//  AssetsSearchViewBuilder.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 05.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit
import DomainLayer

struct AssetsSearchViewBuilder: ModuleBuilderOutput {
    
    struct Input {
        let assets: [DomainLayer.DTO.Asset]
        let limit: Int
    }
    
    var output: AssetsSearchModuleOutput
    
    func build(input: Input) -> UIViewController {
        let vc = StoryboardScene.AssetsSearch.assetsSearchViewController.instantiate()
        vc.system = AssetsSearchSystem(assets: input.assets, limit: input.limit)
        vc.moduleOuput = output
        return vc
    }
}


