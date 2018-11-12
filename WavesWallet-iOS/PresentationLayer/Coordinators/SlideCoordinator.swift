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

    private var wallet: DomainLayer.DTO.Wallet?

    private weak var window: UIWindow?

    private var slideMenuViewController: SlideMenu = {

        let menuController = StoryboardScene.Main.menuViewController.instantiate()
        let slideMenuViewController = SlideMenu(contentViewController: UIViewController(),
                                                leftMenuViewController: menuController,
                                                rightMenuViewController: nil)!
        return slideMenuViewController
    }()

    init(window: UIWindow, wallet: DomainLayer.DTO.Wallet?) {
        self.window = window
        self.wallet = wallet
    }

    func start() {

        if let view = self.window?.rootViewController?.view {
            UIView.transition(from: view, to: slideMenuViewController.view, duration: 0.24, options: [.transitionCrossDissolve], completion: { _ in
                self.window?.rootViewController = self.slideMenuViewController
            })
        } else {
            self.window?.rootViewController = self.slideMenuViewController
        }
        self.window?.makeKeyAndVisible()

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
            let passcodeCoordinator = PasscodeCoordinator(viewController: window!.rootViewController!,
                                                          kind: .logIn(wallet))
            passcodeCoordinator.animated = true
            passcodeCoordinator.delegate = self
            addChildCoordinatorAndStart(childCoordinator: passcodeCoordinator)

        case .wallet:
            let mainTabBarController = MainTabBarCoordinator(slideMenuViewController: slideMenuViewController,
                                                             applicationCoordinator: self)
            addChildCoordinatorAndStart(childCoordinator: mainTabBarController)

        case .enter:
            let enter = EnterCoordinator(slideMenuViewController: slideMenuViewController)
            enter.delegate = self
            addChildCoordinatorAndStart(childCoordinator: enter)
        }
    }
}

// MARK: PasscodeCoordinatorDelegate
extension SlideCoordinator: PasscodeCoordinatorDelegate {

    func passcodeCoordinatorVerifyAcccesCompleted(signedWallet: DomainLayer.DTO.SignedWallet) {}

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
