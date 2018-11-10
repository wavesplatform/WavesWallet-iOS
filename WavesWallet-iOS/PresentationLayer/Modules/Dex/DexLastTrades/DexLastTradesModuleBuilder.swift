//
//  DexLastTradesModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/16/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct DexLastTradesModuleBuilder: ModuleBuilderOutput {
    
    weak var output: DexLastTradesModuleOutput?
    
    func build(input: DexTraderContainer.DTO.Pair) -> UIViewController {
        
        var interactor: DexLastTradesInteractorProtocol = DexLastTradesInteractorMock()
        interactor.pair = input
        
        var presenter: DexLastTradesPresenterProtocol = DexLastTradesPresenter()
        presenter.interactor = interactor
        presenter.moduleOutput = output
        presenter.amountAsset = input.amountAsset
        presenter.priceAsset = input.priceAsset
        
        let vc = StoryboardScene.Dex.dexLastTradesViewController.instantiate()
        vc.presenter = presenter

        return vc
    }
}
