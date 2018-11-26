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

    private let slideMenuViewController: SlideMenu
    private weak var applicationCoordinator: ApplicationCoordinatorProtocol?

    init(slideMenuViewController: SlideMenu, applicationCoordinator: ApplicationCoordinatorProtocol?) {
        self.slideMenuViewController = slideMenuViewController
        self.applicationCoordinator = applicationCoordinator
    }

    func start() {
        let mainTabBar = StoryboardScene.Main.mainTabBarController.instantiate()
        
        mainTabBar.tabBar.isTranslucent = false
        mainTabBar.tabBar.barTintColor = .white
        mainTabBar.tabBar.backgroundImage = UIImage()
        mainTabBar.tabBar.shadowImage = UIColor.accent100.navigationShadowImage()
        
        mainTabBar.applicationCoordinator = applicationCoordinator
        self.slideMenuViewController.contentViewController = mainTabBar
    }
}
