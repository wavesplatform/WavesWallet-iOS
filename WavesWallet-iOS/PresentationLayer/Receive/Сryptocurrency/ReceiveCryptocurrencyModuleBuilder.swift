//
//  ReceiveCryptocurrencyModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/6/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct ReceiveCryptocurrencyModuleBuilder: ModuleBuilder {
    
    func build(input: AssetList.DTO.Input) -> UIViewController {
        
        let interactor: ReceiveCryptocurrencyInteractorProtocol = ReceiveCryptocurrencyInteractor()
        
        var presenter: ReceiveCryptocurrencyPresenterProtocol = ReceiveCryptocurrencyPresenter()
        presenter.interactor = interactor
        
        let vc = StoryboardScene.Receive.receiveCryptocurrencyViewController.instantiate()
        vc.presenter = presenter
        vc.input = input
        
        return vc
    }
}
