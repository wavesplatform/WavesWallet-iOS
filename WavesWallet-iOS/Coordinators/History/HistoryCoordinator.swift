//
//  HistoryCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Mac on 01/08/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit
import RxSwift
import DomainLayer

final class HistoryCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []

    weak var parent: Coordinator?

    private let historyType: HistoryType
    private var navigationRouter: NavigationRouter!
    private let disposeBag: DisposeBag = DisposeBag()

    func start() {

        let historyViewController = HistoryModuleBuilder(output: self)
            .build(input: HistoryInput(inputType: historyType))

        navigationRouter.pushViewController(historyViewController, animated: true) { [weak self] in
            self?.removeFromParentCoordinator()
        }
        setupBackupTost(target: historyViewController, navigationRouter: navigationRouter, disposeBag: disposeBag)
    }

    init(navigationRouter: NavigationRouter, historyType: HistoryType) {

        self.navigationRouter = navigationRouter
        self.historyType = historyType
    }
}


extension HistoryCoordinator: HistoryModuleOutput {
    
    func showTransaction(transaction: DomainLayer.DTO.SmartTransaction) {
        let coordinator = TransactionCardCoordinator(transaction: transaction,
                                                     router: navigationRouter)


        addChildCoordinatorAndStart(childCoordinator: coordinator)
    }
}

extension HistoryCoordinator: HistoryModuleInput {
    
    var type: HistoryType {
        return .all
    }
}
