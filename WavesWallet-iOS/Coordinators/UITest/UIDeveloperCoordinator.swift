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
    
    lazy var coordinator = StakingTransferCoordinator.init(router: self.navigationRouter)
    
    init(windowRouter: WindowRouter) {
        self.windowRouter = windowRouter
        self.navigationRouter = NavigationRouter(navigationController: CustomNavigationController())
    }
    
    func start() {
        
        let builder = PayoutsHistoryBuilder()
        
        let vc = builder.build(input: Void())
        self.navigationRouter.pushViewController(vc)
        self.windowRouter.setRootViewController(self.navigationRouter.viewController,
                                                animated: .none,
                                                completion: {

        })

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.coordinator.start()
        }
        
//        let view = UIViewController()
//        view.view = UIView()
//        view.view.frame = UIScreen.main.bounds
//        view.navigationItem.title = "UIDeveloper"
//        self.navigationRouter.pushViewController(view)
//        self.windowRouter.setRootViewController(self.navigationRouter.viewController,
//                                                animated: .none,
//                                                completion: {
//
//        })
//
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
//            self.coordinator.start()
//        }
    }
}

extension UIDeveloperCoordinator {
    func applicationDidEnterBackground() {}

    func applicationDidBecomeActive() {}
    func openURL(link: DeepLink) {}
}
