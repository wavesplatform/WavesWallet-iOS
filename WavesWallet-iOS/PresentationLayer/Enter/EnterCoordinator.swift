//
//  EnterCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 21/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol EnterCoordinatorDelegate: AnyObject {
    func userCompletedLogIn()
}

final class EnterCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    private let navigationController: UINavigationController
    private var account: NewAccountTypes.DTO.Account?

    weak var delegate: EnterCoordinatorDelegate?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let enter = StoryboardScene.Enter.enterStartViewController.instantiate()
        enter.delegate = self
        navigationController.pushViewController(enter, animated: true)        
    }
}

// MARK: EnterStartViewControllerDelegate

extension EnterCoordinator: EnterStartViewControllerDelegate {

    func showSignInAccount() {
        let vc = StoryboardScene.Enter.enterSelectAccountViewController.instantiate()
        navigationController.pushViewController(vc, animated: true)
    }

    func showImportCoordinator() {
        let coordinator = ImportCoordinator(navigationController: navigationController) { [weak self] account in
            self?.showPasscode(with: .init(privateKey: account.privateKey,
                                           password: account.password,
                                           name: account.name,
                                           needBackup: false))
        }
        addChildCoordinator(childCoordinator: coordinator)
        coordinator.start()
    }

    func showNewAccount() {

        let coordinator = NewAccountCoordinator(navigationController: navigationController) { [weak self] account, needBackup  in
            self?.showPasscode(with: .init(privateKey: account.privateKey,
                                           password: account.password,
                                           name: account.name,
                                           needBackup: needBackup))
        }
        addChildCoordinator(childCoordinator: coordinator)
        coordinator.start()
    }

    func showPasscode(with account: PasscodeTypes.DTO.Account) {

        let passcodeCoordinator = PasscodeCoordinator(viewController: navigationController,
                                                      kind: .registration(account))
        passcodeCoordinator.delegate = self

        addChildCoordinator(childCoordinator: passcodeCoordinator)
        passcodeCoordinator.start()
    }
}

// MARK: PasscodeCoordinatorDelegate
extension EnterCoordinator: PasscodeCoordinatorDelegate {

    func userAuthorizationCompleted() {
        removeFromParentCoordinator()
        delegate?.userCompletedLogIn()
    }
}
