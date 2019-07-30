//
//  UIDeveloperCoordinator.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 28.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

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
        
        let vc = WidgetSettingsModuleBuilder.init(output: .init()).build(input: .init())

        self.navigationRouter.pushViewController(vc, animated: true) { [weak self] in
            guard let self = self else { return }
            self.removeFromParentCoordinator()
        }
        
        self.windowRouter.setRootViewController(self.navigationRouter.navigationController)
    }
}
