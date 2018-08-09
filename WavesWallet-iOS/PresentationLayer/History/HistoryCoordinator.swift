//
//  HistoryCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Mac on 01/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class HistoryCoordinator {
    
    private lazy var historyViewController: UIViewController = {
        return HistoryModuleBuilder(output: self).build(input: HistoryInput(inputType: .all))
    }()
    
    private var navigationController: UINavigationController!
    
    func start(navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigationController.pushViewController(historyViewController, animated: false)
    }
    
}


extension HistoryCoordinator: HistoryModuleOutput {
    
}

extension HistoryCoordinator: HistoryModuleInput {
    
    var type: HistoryType {
        return .all
    }
    
}
