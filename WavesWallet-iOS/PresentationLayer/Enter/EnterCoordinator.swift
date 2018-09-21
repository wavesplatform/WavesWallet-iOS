//
//  EnterCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 21/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class EnterCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    private let navigationController: UINavigationController
    private var account: NewAccountTypes.DTO.Account?

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
//        let controller = storyboard?.instantiateViewController(withIdentifier: "EnterSelectAccountViewController") as! EnterSelectAccountViewController
//        navigationController?.pushViewController(controller, animated: true)
    }

    func showImportCoordinator() {
        let coordinator = ImportCoordinator(navigationController: navigationController) { [weak self] account in
            self?.showPasscode(with: .init(privateKey: account.privateKey,
                                           password: account.password,
                                           name: account.name))
        }
        addChildCoordinator(childCoordinator: coordinator)
        coordinator.start()
    }

    func showNewAccount() {

        let coordinator = NewAccountCoordinator(navigationController: navigationController) { [weak self] account in
            self?.showPasscode(with: .init(privateKey: account.privateKey,
                                           password: account.password,
                                           name: account.name))
        }
        addChildCoordinator(childCoordinator: coordinator)
        coordinator.start()
    }
}

fileprivate extension EnterCoordinator {

    func showPasscode(with account: PasscodeTypes.DTO.Account) {

        let vc = PasscodeModuleBuilder(output: self)
            .build(input: .init(kind: .registration(account)))

        let nv = CustomNavigationController(rootViewController: vc)
        navigationController.present(nv, animated: true, completion: nil)
    }
}

extension EnterCoordinator: PasscodeOutput {

}
