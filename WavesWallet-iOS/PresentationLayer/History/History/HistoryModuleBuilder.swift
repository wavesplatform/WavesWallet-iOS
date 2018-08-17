//
//  HistoryModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Mac on 07/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct HistoryModuleBuilder: ModuleBuilderOutput {
    
    var output: HistoryModuleOutput
    
    func build(input: HistoryModuleInput) -> UIViewController {
        
        let presenter = HistoryPresenter(input: input)
        let vc = StoryboardScene.History.newHistoryViewController.instantiate()
        
        presenter.interactor = HistoryInteractorMock()
        presenter.moduleOutput = output
        vc.presenter = presenter
        
        return vc
        
    }
    
}

struct HistoryInput: HistoryModuleInput {
    
    let inputType: HistoryType
    
    var type: HistoryType {
        return inputType
    }
}
