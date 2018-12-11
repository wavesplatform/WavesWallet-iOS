//
//  DexSortModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/7/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct DexSortModuleBuilder: ModuleBuilderOutput {
    
    var output: DexListRefreshOutput
    
    func build(input: Void) -> UIViewController {
        
        let vc = StoryboardScene.Dex.dexSortViewController.instantiate()
        var presenter: DexSortPresenterProtocol = DexSortPresenter()
        presenter.interactor = DexSortInteractor()
        vc.presenter = presenter
        vc.delegate = output
        
        return vc
    }
}
