//
//  MainTabBarCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 25/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

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
        let mainTabBar = MainTabBarController(applicationCoordinator: applicationCoordinator)        
        self.slideMenuViewController.contentViewController = mainTabBar
    }
}
