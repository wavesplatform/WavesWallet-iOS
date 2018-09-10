//
//  DexOrderBookModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/15/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct DexOrderBookModuleBuilder: ModuleBuilderOutput {
    
    var output: DexOrderBookModuleOutput
    
    func build(input: DexTraderContainer.DTO.Pair) -> UIViewController {
       
        var interactor: DexOrderBookInteractorProtocol = DexOrderBookInteractorMock()
        interactor.pair = input
        
        var presenter: DexOrderBookPresenterProtocol = DexOrderBookPresenter()
        presenter.interactor = interactor
        presenter.moduleOutput = output
        let vc = StoryboardScene.Dex.dexOrderBookViewController.instantiate()
        vc.presenter = presenter
        return vc
    }
    
}
