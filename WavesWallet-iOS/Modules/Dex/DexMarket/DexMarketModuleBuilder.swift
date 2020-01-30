//
//  DexMarketModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/9/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit
import Extensions
import DomainLayer

struct DexMarketModuleBuilder: ModuleBuilderOutput {
    
    weak var output: TradeRefreshOutput?
   
    func build(input: DomainLayer.DTO.Dex.Asset?) -> UIViewController {
        
        let vc = StoryboardScene.Dex.dexMarketViewController.instantiate()
        
        var presenter: DexMarketPresenterProtocol = DexMarketPresenter(selectedAsset: input)
        presenter.interactor = DexMarketInteractor()
        vc.presenter = presenter
        vc.delegate = output
        vc.selectedAsset = input
        
        return vc
    }
}
