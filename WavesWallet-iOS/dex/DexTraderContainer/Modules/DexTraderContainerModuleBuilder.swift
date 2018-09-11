//
//  DexTraderContainerModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/15/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct DexTraderContainerModuleBuilder: ModuleBuilderOutput {
    
    weak var output: DexTraderContainerModuleOutput?
    weak var orderBookOutput: DexOrderBookModuleOutput?
    weak var lastTradesOutput: DexLastTradesModuleOutput?
    
    func build(input: DexTraderContainer.DTO.Pair) -> UIViewController {
        let vc = StoryboardScene.Dex.dexTraderContainerViewController.instantiate()
        vc.pair = input
        vc.moduleOutput = output
        
        vc.addViewController(DexOrderBookModuleBuilder(output: orderBookOutput).build(input: input), isScrollEnabled: true)
        vc.addViewController(DexChartModuleBuilder().build(input: input), isScrollEnabled: false)
        vc.addViewController(DexLastTradesModuleBuilder(output: lastTradesOutput).build(input: input), isScrollEnabled: true)
        vc.addViewController(DexMyOrdersModuleMuilder().build(input: input), isScrollEnabled: true)
        return vc
    }
}

