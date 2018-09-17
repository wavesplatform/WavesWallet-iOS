//
//  NewAccountCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 17/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class NewAccountCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var parent: Coordinator?

    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = StoryboardScene.NewAccount.newAccountViewController.instantiate()
        self.navigationController.pushViewController(vc, animated: true)
    }
}
