//
//  AssetListModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/5/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct AssetListModuleBuilder: ModuleBuilderOutput {
    
    var output: AssetListModuleOutput
    
    struct Input {
        let filters: [AssetList.DTO.Filter]
        let selectedAsset: DomainLayer.DTO.AssetBalance?
    }
    
    func build(input: Input) -> UIViewController {
        
        let interactor: AssetListInteractorProtocol = AssetListInteractor()
        let presenter = AssetListPresenter()
        presenter.interactor = interactor
        presenter.filters = input.filters
        presenter.moduleOutput = output
        
        let vc = StoryboardScene.AssetList.assetListViewController.instantiate()
        vc.presenter = presenter
        vc.selectedAsset = input.selectedAsset
        
        return vc
    }
}
