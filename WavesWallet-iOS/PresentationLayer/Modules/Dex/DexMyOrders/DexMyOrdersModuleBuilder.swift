//
//  DexMyOrdersModuleMuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/16/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct DexMyOrdersModuleBuilder: ModuleBuilderOutput {
    
    weak var output: DexMyOrdersModuleOutput?
    
    func build(input: DexTraderContainer.DTO.Pair) -> UIViewController {

        var interactor: DexMyOrdersInteractorProtocol = DexMyOrdersInteractor()
        interactor.pair = input
        
        var presenter: DexMyOrdersPresenterProtocol = DexMyOrdersPresenter()
        presenter.interactor = interactor
        
        let vc = StoryboardScene.Dex.dexMyOrdersViewController.instantiate()
        vc.presenter = presenter
        vc.output = output
        
        return vc
    }
}
