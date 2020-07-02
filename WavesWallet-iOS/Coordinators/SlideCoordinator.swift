//
//  SlideCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 06/11/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Intercom
import RxSwift
import UIKit

final class SlideCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    private let wallet: Wallet?

    private let windowRouter: WindowRouter
    private let disposeBag = DisposeBag()

    weak var menuViewControllerDelegate: MenuViewControllerDelegate?



    init(windowRouter: WindowRouter, wallet: Wallet?) {
        self.windowRouter = windowRouter
        self.wallet = wallet
    }

    func start() {
        if let wallet = wallet {
            showDisplay(.wallet(wallet))
        } else {
            showDisplay(.enter)
        }
    }
}

// MARK: PresentationCoordinator

extension SlideCoordinator: PresentationCoordinator {
    enum Display {
        case wallet(Wallet)
        case enter
    }

    func showDisplay(_ display: Display) {
        switch display {
        case .wallet:

            removeCoordinators()
            let mainTabBarController = MainTabBarCoordinator(windowRouter: windowRouter,
                                                             applicationCoordinator: self)
            addChildCoordinatorAndStart(childCoordinator: mainTabBarController)

        case .enter:
            removeCoordinators()

            let enter = EnterCoordinator(windowRouter: windowRouter, applicationCoordinator: self)
            enter.delegate = self
            addChildCoordinatorAndStart(childCoordinator: enter)
        }
    }
}

// MARK: ApplicationCoordinatorProtocol

extension SlideCoordinator: ApplicationCoordinatorProtocol {
    func showEnterDisplay() {
        Intercom.logout()
        showDisplay(.enter)
    }
}

// MARK: EnterCoordinatorDelegate

extension SlideCoordinator: EnterCoordinatorDelegate {
    func userCompletedLogIn(wallet: Wallet) {
        showDisplay(.wallet(wallet))
    }
}
