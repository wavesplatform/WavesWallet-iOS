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
    func showTransaction() {
        let controller = StoryboardManager.TransactionsStoryboard().instantiateViewController(withIdentifier: "TransactionHistoryViewController") as! TransactionHistoryViewController
        controller.items = [NSDictionary()]
        controller.currentPage = 0
        
        let popup = PopupViewController()
        popup.present(contentViewController: controller)
    }
}

extension HistoryCoordinator: HistoryModuleInput {
    
    var type: HistoryType {
        return .all
    }
    
}
