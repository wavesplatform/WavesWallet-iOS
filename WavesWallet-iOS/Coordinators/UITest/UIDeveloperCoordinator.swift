//
//  UIDeveloperCoordinator.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 28.07.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import UIKit
import Extensions

final class UIDeveloperCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?
    
    private var windowRouter: WindowRouter
    private var navigationRouter: NavigationRouter
    
    weak var delegate: HelloCoordinatorDelegate?
    
    init(windowRouter: WindowRouter) {
        self.windowRouter = windowRouter
        self.navigationRouter = NavigationRouter(navigationController: CustomNavigationController())
    }
    
    func start() {
                
//        self.windowRouter.setRootViewController(emptyVC())
//
//        let coordinator = StakingTransferCoordinator(router: self.windowRouter, kind: .card)
//
//        addChildCoordinator(childCoordinator: coordinator)
//        coordinator.start()
        
    }
}
    
extension UIDeveloperCoordinator {
    func applicationDidEnterBackground() {}

    func applicationDidBecomeActive() {}
    func openURL(link: DeepLink) {}
}

extension UIDeveloperCoordinator {
    
    func emptyVC() -> UIViewController {
        let vc = UIViewController()
        vc.view =  UIView()
        vc.view.backgroundColor = .orangeYellowTwo
        vc.view.frame = UIScreen.main.bounds
        return vc
    }
}
