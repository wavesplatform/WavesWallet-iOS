//
//  TransactionHistoryModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Mac on 29/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct TransactionHistoryModuleBuilder: ModuleBuilderOutput {

    struct Input: TransactionHistoryModuleInput {
        let transactions: [DomainLayer.DTO.SmartTransaction]
        let currentIndex: Int
    }

    var output: TransactionHistoryModuleOutput

    func build(input: Input) -> UIViewController {
    
        let presenter = TransactionHistoryPresenter(input: input)
        let vc = StoryboardScene.TransactionHistory.transactionHistoryViewController.instantiate()
        
        presenter.interactor = TransactionHistoryInteractorMock()
        presenter.moduleOutput = output
        vc.presenter = presenter
        
        return vc
        
    }
}


