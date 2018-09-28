//
//  DexSellBuyModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/11/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct DexCreateOrderModuleBuilder: ModuleBuilderOutput {
    
    weak var output: DexCreateOrderModuleOutput?

    func build(input: DexCreateOrder.DTO.Input) -> UIViewController {
        
        let interactor: DexCreateOrderInteractorProtocol = DexCreateOrderInteractorMock()
        
        var presenter: DexCreateOrderPresenterProtocol = DexCreateOrderPresenter()
        presenter.interactor = interactor
        presenter.moduleOutput = output
        
        let vc = StoryboardScene.Dex.dexCreateOrderViewController.instantiate()
        vc.input = input
        vc.presenter = presenter
        
        return vc
    }
}
