//
//  ImportCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 20.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class ImportCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = StoryboardScene.Import.importAccountViewController.instantiate()
        vc.delegate = self
        self.navigationController.pushViewController(vc, animated: true)
    }
}

extension ImportCoordinator: ImportAccountViewControllerDelegate {

    func enterManuallyTapped() {

        let vc = StoryboardScene.Import.importWelcomeBackViewController.instantiate()
        vc.delegate = self
        navigationController.pushViewController(vc, animated: true)
    }

    func scanedSeed(_ seed: String) {

    }
}

extension ImportCoordinator: ImportWelcomeBackViewControllerDelegate {
    func userCompletedInputSeed(_ keyAccount: PrivateKeyAccount) {

        let vc = StoryboardScene.Import.importAccountPasswordViewController.instantiate()
        navigationController.pushViewController(vc, animated: true)
        
    }
}
