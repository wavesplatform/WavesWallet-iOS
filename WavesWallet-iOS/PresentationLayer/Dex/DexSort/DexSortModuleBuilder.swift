//
//  DexSortModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/7/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct DexSortModuleBuilder: ModuleBuilder {
    
    func build(input: Void) -> UIViewController {
        
        let vc = StoryboardScene.Dex.dexSortViewController.instantiate()
        var presenter: DexSortPresenterProtocol = DexSortPresenter()
        presenter.interactor = DexSortInteractorMock()
        vc.presenter = presenter
        
        return vc
    }
}
