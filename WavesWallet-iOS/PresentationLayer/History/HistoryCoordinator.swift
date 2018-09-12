//
//  HistoryCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Mac on 01/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class HistoryCoordinator {
    
    private weak var historyViewController: UIViewController?
    
    private var navigationController: UINavigationController!
    
    func start(navigationController: UINavigationController, historyType: HistoryType) {
        self.navigationController = navigationController

        historyViewController = HistoryModuleBuilder(output: self).build(input: HistoryInput(inputType: historyType))
        navigationController.pushViewController(historyViewController!, animated: true)
    }
    
}


extension HistoryCoordinator: HistoryModuleOutput {
    func showTransaction() {
        let controller = StoryboardManager.TransactionsStoryboard().instantiateViewController(withIdentifier: "TransactionHistoryViewController") as! TransactionHistoryViewController
        controller.items = [NSDictionary()]
        controller.currentPage = 0
        
        let popup = PopupViewController()
//        popup.present(contentViewController: controller)
    }
}
