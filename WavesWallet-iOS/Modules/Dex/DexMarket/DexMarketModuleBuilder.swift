//
//  DexMarketModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/9/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit
import Extensions

struct DexMarketModuleBuilder: ModuleBuilderOutput {
    
    weak var output: DexMarketModuleOutput?
   
    func build(input: DexMarket.DTO.Input) -> UIViewController {
        
        let vc = StoryboardScene.Dex.dexMarketViewController.instantiate()
        
        var presenter: DexMarketPresenterProtocol = DexMarketPresenter(selectedAsset: input.selectedAsset)
        presenter.interactor = DexMarketInteractor()
        presenter.moduleOutput = output
        vc.presenter = presenter
        vc.delegate = input.delegate
        vc.selectedAsset = input.selectedAsset
        
        return vc
    }
}
