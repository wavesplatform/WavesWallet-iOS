//
//  DexCompleteOrderModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/21/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class DexCompleteOrderModuleBuilder: ModuleBuilder {
    
    func build(input: DexCreateOrder.DTO.Output) -> UIViewController {
        
        let vc = StoryboardScene.Dex.dexCompleteOrderViewController.instantiate()
        vc.input = input
        return vc
    }
}
