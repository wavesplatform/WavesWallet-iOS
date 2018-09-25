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

    init(slideMenuViewController: SlideMenu) {
        self.slideMenuViewController = slideMenuViewController
    }

    func start() {

    }
}
