//
//  DexMarketModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/9/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct DexMarketModuleBuilder: ModuleBuilderOutput {
    
    weak var output: DexMarketModuleOutput?
   
    func build(input: DexMarketDelegate) -> UIViewController {
        
        let vc = StoryboardScene.Dex.dexMarketViewController.instantiate()
        
        var presenter: DexMarketPresenterProtocol = DexMarketPresenter()
        presenter.interactor = DexMarketInteractor()
        presenter.moduleOutput = output
        vc.presenter = presenter
        vc.delegate = input
        
        return vc
    }
}
