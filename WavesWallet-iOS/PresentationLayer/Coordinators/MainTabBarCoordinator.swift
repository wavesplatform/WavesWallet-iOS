//
//  MainTabBarCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 25/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class MainTabBarCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    private let slideMenuRouter: SlideMenuRouter
    private weak var applicationCoordinator: ApplicationCoordinatorProtocol?

    init(slideMenuRouter: SlideMenuRouter, applicationCoordinator: ApplicationCoordinatorProtocol?) {
        self.slideMenuRouter = slideMenuRouter
        self.applicationCoordinator = applicationCoordinator
    }

    func start() {
        let mainTabBar = StoryboardScene.Main.mainTabBarController.instantiate()
        
        mainTabBar.tabBar.isTranslucent = false
        mainTabBar.tabBar.barTintColor = .white
        mainTabBar.tabBar.backgroundImage = UIImage()
        mainTabBar.tabBar.shadowImage = UIImage.shadowImage(color: .accent100)
        mainTabBar.applicationCoordinator = applicationCoordinator        
        slideMenuRouter.setContentViewController(mainTabBar)
    }
}
