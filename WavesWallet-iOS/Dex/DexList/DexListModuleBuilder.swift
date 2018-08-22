//
//  DexListModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/7/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct DexListModuleBuilder: ModuleBuilderOutput {
    
    var output: DexListModuleOutput
    
    func build(input: Void) -> UIViewController {
        
        let vc = StoryboardScene.Dex.dexListViewController.instantiate()
        let presenter = DexListPresenter()
        presenter.interactor = DexListInteractorMock()
        presenter.moduleOutput = output
        vc.presenter = presenter
        
        return vc
    }
}
