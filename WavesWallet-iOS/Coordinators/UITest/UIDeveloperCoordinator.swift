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
        let payoutsBuilder = PayoutsHistoryBuilder()
        let vc = payoutsBuilder.build()
        
        let navController = CustomNavigationController(rootViewController: vc)
        
        windowRouter.window.rootViewController = navController
        windowRouter.window.makeKeyAndVisible()
        
//        let coordinator = TradeCoordinator(navigationRouter: navigationRouter)
//        
//        addChildCoordinatorAndStart(childCoordinator: coordinator)
//                
//        let vc = TradeModuleBuilder(output: self).bui
//        navigationRouter.pushViewController(vc)
//        self.windowRouter.setRootViewController(self.navigationRouter.navigationController)
    }
}

extension UIDeveloperCoordinator: TooltipViewControllerModulOutput {
    func tooltipDidTapClose() {
        
    }
}
    
extension UIDeveloperCoordinator {
    func applicationDidEnterBackground() {}

    func applicationDidBecomeActive() {}
    func openURL(link: DeepLink) {}
}
