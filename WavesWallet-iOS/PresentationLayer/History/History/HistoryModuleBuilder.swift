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
        
        presenter.interactor = HistoryInteractor()
        presenter.moduleOutput = output
        vc.presenter = presenter

        //TODO: Нужно подумать как лучше это сделать
        switch input.type {
        case .all:
            vc.createMenuButton()

        default:
            vc.createBackButton()
        }
        
        return vc
    }
}

struct HistoryInput: HistoryModuleInput {
    
    let inputType: HistoryType
    
    var type: HistoryType {
        return inputType
    }
}
