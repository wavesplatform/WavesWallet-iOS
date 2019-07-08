//
//  DexScriptAssetMessageModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 3/5/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit

protocol DexScriptAssetMessageModuleOutput: AnyObject {
    func dexScriptAssetMessageModuleOutputDidTapCheckmark(amountAsset: String, priceAsset: String, doNotShow: Bool)
}

struct DexScriptAssetMessageModuleBuilder: ModuleBuilderOutput {
    
    struct Input {
        let assets: [DomainLayer.DTO.Asset]
        let amountAsset: String
        let priceAsset: String
        let continueAction: (() -> Void)?
    }
    
    var output: DexScriptAssetMessageModuleOutput
    
    func build(input: Input) -> UIViewController {
        
        let vc = StoryboardScene.Dex.dexScriptAssetMessageViewController.instantiate()
        vc.input = input
        vc.output = output
        return vc
    }
}
