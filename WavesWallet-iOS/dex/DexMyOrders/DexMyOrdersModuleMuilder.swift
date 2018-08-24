//
//  DexMyOrdersModuleMuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/16/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct DexMyOrdersModuleMuilder: ModuleBuilder {
    
    func build(input: Void) -> UIViewController {

        var presenter: DexMyOrdersPresenterProtocol = DexMyOrdersPresenter()
        presenter.interactor = DexMyOrdersInteractorMock()
        
        let vc = StoryboardScene.Dex.dexMyOrdersViewController.instantiate()
        vc.presenter = presenter
        return vc
    }
}
