//
//  HistoryCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Mac on 01/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift

final class HistoryCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []

    weak var parent: Coordinator?

    private let historyType: HistoryType
    private var navigationController: UINavigationController!
    private let disposeBag: DisposeBag = DisposeBag()

    func start() {

        let historyViewController = HistoryModuleBuilder(output: self).build(input: HistoryInput(inputType: historyType))

        navigationController.pushViewController(historyViewController, animated: true)

        setupBackupTost(target: historyViewController, navigationController: navigationController, disposeBag: disposeBag)
    }

    init(navigationController: UINavigationController, historyType: HistoryType) {

        self.navigationController = navigationController
        self.historyType = historyType
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
