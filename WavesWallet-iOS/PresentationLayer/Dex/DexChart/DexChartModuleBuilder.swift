//
//  DexChartModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/16/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct DexChartModuleBuilder: ModuleBuilder {
    
    func build(input: DexTraderContainer.DTO.Pair) -> UIViewController {
        
        var interactor: DexChartInteractorProtocol = DexChartInteractorMock()
        interactor.pair = input
        
        var presenter: DexChartPresenterProtocol = DexChartPresenter()
        presenter.interactor = interactor
        
        let vc = StoryboardScene.Dex.dexChartViewController.instantiate()
        vc.presenter = presenter
        vc.pair = input
        return vc
    }
}


