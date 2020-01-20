//
//  TradeModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 09.01.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import Extensions

struct TradeModuleBuilder: ModuleBuilder {
    
    func build(input: Void) -> UIViewController {
        let vc = StoryboardScene.Trade.tradeViewController.instantiate()
        vc.system = TradeSystem()
        return vc
    }
}
