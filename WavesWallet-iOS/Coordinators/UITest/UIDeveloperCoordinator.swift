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
    
    lazy var coordinator = StakingTransferCoordinator.init(router: self.windowRouter)
    
    init(windowRouter: WindowRouter) {
        self.windowRouter = windowRouter
        self.navigationRouter = NavigationRouter(navigationController: CustomNavigationController())
    }
    
    func start() {
        
        self.windowRouter.setRootViewController(UIViewController())
        
        
        coordinator.start()
        
        
    }
}

extension UIDeveloperCoordinator {
    func applicationDidEnterBackground() {}

    func applicationDidBecomeActive() {}
    func openURL(link: DeepLink) {}
}
