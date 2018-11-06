//
//  EnterCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 21/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol EnterCoordinatorDelegate: AnyObject {
    func userCompletedLogIn(wallet: DomainLayer.DTO.Wallet)
}

final class EnterCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    private weak var slideMenuViewController: SlideMenu?
    private let navigationController: UINavigationController
    private var account: NewAccountTypes.DTO.Account?

    weak var delegate: EnterCoordinatorDelegate?

    init(slideMenuViewController: SlideMenu) {
        self.slideMenuViewController = slideMenuViewController
        self.navigationController = CustomNavigationController()
    }

    func start() {
        let enter = StoryboardScene.Enter.enterStartViewController.instantiate()
        enter.delegate = self
        self.navigationController.pushViewController(enter, animated: false)
        self.slideMenuViewController?.contentViewController = self.navigationController
    }
}

// MARK: EnterStartViewControllerDelegate

extension EnterCoordinator: EnterStartViewControllerDelegate {

    func showSignInAccount() {
        let chooseAccountCoordinator = ChooseAccountCoordinator(navigationController: navigationController)
        chooseAccountCoordinator.delegate = self
        addChildCoordinator(childCoordinator: chooseAccountCoordinator)
        chooseAccountCoordinator.start()
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
    
    func showLanguageCoordinator() {
        let languageCoordinator = EnterLanguageCoordinator(parentController: navigationController)
        addChildCoordinator(childCoordinator: languageCoordinator)
        languageCoordinator.start()
    }
}

// MARK: PasscodeCoordinatorDelegate
extension EnterCoordinator: PasscodeCoordinatorDelegate {
    
    func passcodeCoordinatorVerifyAcccesCompleted(signedWallet: DomainLayer.DTO.SignedWallet) {}

    func passcodeCoordinatorAuthorizationCompleted(wallet: DomainLayer.DTO.Wallet) {
        removeFromParentCoordinator()
        delegate?.userCompletedLogIn(wallet: wallet)
    }

    func passcodeCoordinatorWalletLogouted() {}
}

// MARK: PasscodeCoordinatorDelegate
extension EnterCoordinator: ChooseAccountCoordinatorDelegate {

    func userChooseCompleted(wallet: DomainLayer.DTO.Wallet) {
        removeFromParentCoordinator()
        delegate?.userCompletedLogIn(wallet: wallet)
    }    
}
