//
//  DexSellBuyModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/11/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct DexCreateOrderModuleBuilder: ModuleBuilder {
    
    func build(input: DexCreateOrder.DTO.Input) -> UIViewController {
        let vc = StoryboardScene.Dex.dexCreateOrderViewController.instantiate()
        vc.input = input
        return vc
    }
}
