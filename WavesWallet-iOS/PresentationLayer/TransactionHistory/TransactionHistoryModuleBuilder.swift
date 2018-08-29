//
//  TransactionHistoryModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Mac on 29/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct TransactionHistoryModuleBuilder: ModuleBuilderOutput {
    
    var output: TransactionHistoryModuleOutput
    
    func build(input: TransactionHistoryModuleInput) -> UIViewController {
    
        let presenter = TransactionHistoryPresenter(input: input)
        let vc = TransactionHistoryViewController()
        
        presenter.interactor = TransactionHistoryInteractorMock()
        presenter.moduleOutput = output
        vc.presenter = presenter
        
        return vc
        
    }
    
}


