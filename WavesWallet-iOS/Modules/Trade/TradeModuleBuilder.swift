//
//  TradeModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 09.01.2020.
//  Copyright © 2020 Waves.Exchange. All rights reserved.
//

import Foundation
import Extensions
import DomainLayer

protocol TradeRefreshOutput: AnyObject {
    func pairsDidChange()
}

protocol TradeModuleOutput: AnyObject {

    func myOrdersTapped()
    func searchTapped(selectedAsset: Asset?, delegate: TradeRefreshOutput)
    func tradeDidDissapear()
    func showTradePairInfo(pair: DexTraderContainer.DTO.Pair)
    func showPairLocked(pair: DexTraderContainer.DTO.Pair)
}

struct TradeModuleBuilder: ModuleBuilderOutput {
        
    var output: TradeModuleOutput
    
    func build(input: Asset?) -> UIViewController {
        let vc = StoryboardScene.Trade.tradeViewController.instantiate()
        vc.system = TradeSystem(selectedAsset: input)
        vc.selectedAsset = input
        vc.output = output
        
        return vc
    }
}
