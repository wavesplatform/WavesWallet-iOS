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
    private let completed: ((ImportTypes.DTO.Account) -> Void)

    private var currentPrivateKeyAccount: PrivateKeyAccount?

    init(navigationController: UINavigationController, completed: @escaping ((ImportTypes.DTO.Account) -> Void)) {
        self.navigationController = navigationController
        self.completed = completed
    }

    func start() {
        let vc = StoryboardScene.Import.importAccountViewController.instantiate()
        vc.delegate = self
        self.navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: ImportAccountViewControllerDelegate
extension ImportCoordinator: ImportAccountViewControllerDelegate {

    func enterManuallyTapped() {
        let vc = StoryboardScene.Import.importWelcomeBackViewController.instantiate()
        vc.delegate = self
        navigationController.pushViewController(vc, animated: true)
    }

    func scanedSeed(_ seed: String) {
        currentPrivateKeyAccount = PrivateKeyAccount(seedStr: seed)
        showAccountPassword(currentPrivateKeyAccount!)
    }
}

// MARK: ImportWelcomeBackViewControllerDelegate
extension ImportCoordinator: ImportWelcomeBackViewControllerDelegate {
    func userCompletedInputSeed(_ keyAccount: PrivateKeyAccount) {
        currentPrivateKeyAccount = keyAccount
        showAccountPassword(keyAccount)
    }
}

private extension ImportCoordinator {

    func showAccountPassword(_ keyAccount: PrivateKeyAccount) {
        let vc = StoryboardScene.Import.importAccountPasswordViewController.instantiate()
        vc.delegate = self
        vc.address = keyAccount.address
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: ImportAccountPasswordViewControllerDelegate
extension ImportCoordinator: ImportAccountPasswordViewControllerDelegate {
    func userCompletedInputAccountData(password: String, name: String) {

        guard let privateKeyAccount = currentPrivateKeyAccount else { return }

        completed(.init(privateKey: privateKeyAccount,
                        password: password,
                        name: name))
    }
}
