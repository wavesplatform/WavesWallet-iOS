//
//  TradeModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 09.01.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import Extensions
import DomainLayer

struct TradeModuleBuilder: ModuleBuilder {
        
    func build(input: DomainLayer.DTO.Asset?) -> UIViewController {
        let vc = StoryboardScene.Trade.tradeViewController.instantiate()
        vc.system = TradeSystem()
        vc.asset = input
        return vc
    }
}
