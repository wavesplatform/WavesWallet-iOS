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
        case passcode(DomainLayer.DTO.Wallet)
        case wallet(DomainLayer.DTO.Wallet)
        case enter
    }

    func showDisplay(_ display: Display) {
        switch display {
        case .passcode(let wallet):
            break
//            let passcodeCoordinator = PasscodeCoordinator(viewController: window!.rootViewController!,
//                                                          kind: .logIn(wallet))
//            passcodeCoordinator.animated = true
//            passcodeCoordinator.delegate = self
//            addChildCoordinatorAndStart(childCoordinator: passcodeCoordinator)

        case .wallet:
            break
//            let mainTabBarController = MainTabBarCoordinator(slideMenuViewController: slideMenuViewController,
//                                                             applicationCoordinator: self)
//            addChildCoordinatorAndStart(childCoordinator: mainTabBarController)

        case .enter:
            let enter = EnterCoordinator(slideMenuRouter: slideMenuRouter, applicationCoordinator: self)
            enter.delegate = self
            addChildCoordinatorAndStart(childCoordinator: enter)
        }
    }
}

// MARK: PasscodeCoordinatorDelegate
extension SlideCoordinator: PasscodeCoordinatorDelegate {

    func passcodeCoordin    atorVerifyAcccesCompleted(signedWallet: DomainLayer.DTO.SignedWallet) {}

    func passcodeCoordinatorAuthorizationCompleted(wallet: DomainLayer.DTO.Wallet) {
        showDisplay(.wallet(wallet))
    }

    func passcodeCoordinatorWalletLogouted() {
        showDisplay(.enter)
    }
}

// MARK: ApplicationCoordinatorProtocol
extension SlideCoordinator: ApplicationCoordinatorProtocol {
    func showEnterDisplay() {
        self.removeCoordinators()
        showDisplay(.enter)
    }
}

// MARK: EnterCoordinatorDelegate
extension SlideCoordinator: EnterCoordinatorDelegate  {
    func userCompletedLogIn(wallet: DomainLayer.DTO.Wallet) {
        showDisplay(.wallet(wallet))
    }
}
