//
//  DexLastTradesModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/16/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct DexLastTradesModuleBuilder: ModuleBuilder {
    
    func build(input: DexTraderContainer.DTO.Pair) -> UIViewController {
        
        var interactor: DexLastTradesInteractorProtocol = DexLastTradesInteractorMock()
        interactor.pair = input
        
        var presenter: DexLastTradesPresenterProtocol = DexLastTradesPresenter()
        presenter.interactor = interactor

        let vc = StoryboardScene.Dex.dexLastTradesViewController.instantiate()
        vc.presenter = presenter

        return vc
    }
}
