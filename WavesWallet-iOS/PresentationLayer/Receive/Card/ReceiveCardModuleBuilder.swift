//
//  ReceiveCardModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/10/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct ReceiveCardModuleBuilder: ModuleBuilder  {
    
    func build(input: Void) -> UIViewController {
        
        let interactor: ReceiveCardInteractorProtocol = ReceiveCardInteractor()
        
        var presenter: ReceiveCardPresenterProtocol = ReceiveCardPresenter()
        presenter.interactor = interactor
        
        let vc = StoryboardScene.Receive.receiveCardViewController.instantiate()
        vc.presenter = presenter
        return vc
    }
}
