//
//  SendModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/15/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct SendModuleBuilder: ModuleBuilder {
    
    func build(input: DomainLayer.DTO.AssetBalance?) -> UIViewController {
        
        var asset = input
        asset?.balance = 12323131
        
        let interactor: SendInteractorProtocol = SendInteractor()
        
        var presenter: SendPresenterProtocol = SendPresenter()
        presenter.interactor = interactor
        
        let vc = StoryboardScene.Send.sendViewController.instantiate()
//        vc.input = .init(filters: [.all], selectedAsset: input)
        vc.input = .init(filters: [.all], selectedAsset: asset)

        vc.presenter = presenter
        
        return vc
    }
}
