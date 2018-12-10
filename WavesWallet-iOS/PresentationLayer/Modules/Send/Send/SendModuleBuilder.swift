//
//  SendModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/15/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct SendModuleBuilder: ModuleBuilder {

    func build(input: Send.DTO.InputModel) -> UIViewController {
        
        let interactor: SendInteractorProtocol = SendInteractor()
        
        var presenter: SendPresenterProtocol = SendPresenter()
        presenter.interactor = interactor
        
        let vc = StoryboardScene.Send.sendViewController.instantiate()
        
        vc.inputModel = input
        vc.presenter = presenter
        
        return vc
    }
}
