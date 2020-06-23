//
//  SlideCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 06/11/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit
import RxSwift
import DomainLayer
import Intercom

final class SlideCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    private let wallet: Wallet?

    private let windowRouter: WindowRouter
    private let slideMenuRouter: SlideMenuRouter
    private let disposeBag = DisposeBag()
    
    weak var menuViewControllerDelegate: MenuViewControllerDelegate?
    
    init(windowRouter: WindowRouter, wallet: Wallet?) {
        self.windowRouter = windowRouter
        self.wallet = wallet
        self.slideMenuRouter = SlideMenuRouter(slideMenu: SlideMenu(contentViewController: UIViewController(),
                                                                    leftMenuViewController: UIViewController(),
                                                                    rightMenuViewController: nil))
    }

    func start() {

        self.windowRouter.setRootViewController(slideMenuRouter.slideMenu, animated: nil)
    
        
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
        Intercom.logout()
        showDisplay(.enter)
    }
}

// MARK: EnterCoordinatorDelegate
extension SlideCoordinator: EnterCoordinatorDelegate  {
    func userCompletedLogIn(wallet: Wallet) {
        showDisplay(.wallet(wallet))
    }
}
