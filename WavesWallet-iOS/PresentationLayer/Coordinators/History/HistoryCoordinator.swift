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
    private var navigationRouter: NavigationRouter!
    private let disposeBag: DisposeBag = DisposeBag()

    func start() {

        let historyViewController = HistoryModuleBuilder(output: self)
            .build(input: HistoryInput(inputType: historyType))

        navigationRouter.pushViewController(historyViewController)
        setupBackupTost(target: historyViewController, navigationRouter: navigationRouter, disposeBag: disposeBag)
    }

    init(navigationRouter: NavigationRouter, historyType: HistoryType) {

        self.navigationRouter = navigationRouter
        self.historyType = historyType
    }
}


extension HistoryCoordinator: HistoryModuleOutput {
    func showTransaction(transactions: [DomainLayer.DTO.SmartTransaction], index: Int) {
        let coordinator = TransactionHistoryCoordinator(transactions: transactions,
                                                        currentIndex: index,
                                                        router: navigationRouter)

        addChildCoordinatorAndStart(childCoordinator: coordinator)
    }
}

extension HistoryCoordinator: HistoryModuleInput {
    
    var type: HistoryType {
        return .all
    }
}
