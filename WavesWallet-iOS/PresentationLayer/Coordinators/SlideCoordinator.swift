//
//  SlideCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 06/11/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class SlideCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    private let wallet: DomainLayer.DTO.Wallet?

    private let windowRouter: WindowRouter
    private let slideMenuRouter: SlideMenuRouter

    init(windowRouter: WindowRouter, wallet: DomainLayer.DTO.Wallet?) {
        self.windowRouter = windowRouter
        self.wallet = wallet
        self.slideMenuRouter = SlideMenuRouter(slideMenu: SlideMenu(contentViewController: UIViewController(),
                                                                    leftMenuViewController: UIViewController(),
                                                                    rightMenuViewController: nil))
    }

    func start() {

        let menuController = StoryboardScene.Main.menuViewController.instantiate()
        slideMenuRouter.setLeftMenuViewController(menuController)
        self.windowRouter.setRootViewController(slideMenuRouter.slideMenu, animated: .crossDissolve)

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
        case wallet(DomainLayer.DTO.Wallet)
        case enter
    }

    func showDisplay(_ display: Display) {
        
        switch display {
        case .wallet:
            self.removeCoordinators()
            let mainTabBarController = MainTabBarCoordinator(slideMenuRouter: slideMenuRouter,
                                                             applicationCoordinator: self)
            addChildCoordinatorAndStart(childCoordinator: mainTabBarController)

        case .enter:
            self.removeCoordinators()

            let enter = EnterCoordinator(slideMenuRouter: slideMenuRouter, applicationCoordinator: self)
            enter.delegate = self
            addChildCoordinatorAndStart(childCoordinator: enter)
        }
    }
}

// MARK: ApplicationCoordinatorProtocol
extension SlideCoordinator: ApplicationCoordinatorProtocol {
    func showEnterDisplay() {
        showDisplay(.enter)
    }
}

// MARK: EnterCoordinatorDelegate
extension SlideCoordinator: EnterCoordinatorDelegate  {
    func userCompletedLogIn(wallet: DomainLayer.DTO.Wallet) {
        showDisplay(.wallet(wallet))
    }
}
