//
//  StartLeasingModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/29/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct StartLeasingModuleBuilder: ModuleBuilderOutput {
    
    var output: StartLeasingModuleOutput
    
    func build(input: Money) -> UIViewController {
        
        let interactor: StartLeasingInteractorProtocol = StartLeasingInteractorMock()
        
        var presenter: StartLeasingPresenterProtocol = StartLeasingPresenter()
        presenter.interactor = interactor
        presenter.moduleOutput = output
        
        let vc = StoryboardScene.StartLeasing.startLeasingViewController.instantiate()
        vc.totalBalance = input
        vc.presenter = presenter
        
        return vc
    }
}
