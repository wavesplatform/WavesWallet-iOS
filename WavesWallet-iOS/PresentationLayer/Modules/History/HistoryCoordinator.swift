//
//  HistoryCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Mac on 01/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class HistoryCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []

    weak var parent: Coordinator?

    private weak var historyViewController: UIViewController?
    
    private var navigationController: UINavigationController!

    func start() {
        navigationController.pushViewController(historyViewController!, animated: true)
    }

    init(navigationController: UINavigationController, historyType: HistoryType) {

        self.navigationController = navigationController
        historyViewController = HistoryModuleBuilder(output: self).build(input: HistoryInput(inputType: historyType))
    }
}


extension HistoryCoordinator: HistoryModuleOutput {
    func showTransaction(transactions: [DomainLayer.DTO.SmartTransaction], index: Int) {
        let coordinator = TransactionHistoryCoordinator(transactions: transactions,
                                                        currentIndex: index,
                                                        navigationController: navigationController)

        addChildCoordinatorAndStart(childCoordinator: coordinator)
    }
}

extension HistoryCoordinator: HistoryModuleInput {
    
    var type: HistoryType {
        return .all
    }
}
