//
//  DexMyOrdersModuleMuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/16/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct DexMyOrdersModuleBuilder: ModuleBuilder {
    
    func build(input: DexTraderContainer.DTO.Pair) -> UIViewController {

        var interactor: DexMyOrdersInteractorProtocol = DexMyOrdersInteractorMock()
        interactor.pair = input
        
        var presenter: DexMyOrdersPresenterProtocol = DexMyOrdersPresenter()
        presenter.interactor = interactor
        
        let vc = StoryboardScene.Dex.dexMyOrdersViewController.instantiate()
        vc.presenter = presenter
        return vc
    }
}
