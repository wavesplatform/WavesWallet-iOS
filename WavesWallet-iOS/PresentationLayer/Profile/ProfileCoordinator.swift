//
//  ProfileCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 04/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum State {
    case backupPhrase
}

final class ProfileCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?
    private let navigationController: UINavigationController
    private var state: State?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = ProfileModuleBuilder(output: self).build()
        self.navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: ProfileModuleOutput

extension ProfileCoordinator: ProfileModuleOutput {

    func showBackupPhrase(wallet: DomainLayer.DTO.Wallet, completed: ((_ isBackedUp: Bool) -> Void)) {

        self.state = .backupPhrase
        // TODO: Need add Auth Kind to passcode
        let passcode = PasscodeCoordinator(navigationController: navigationController, kind: .logIn(wallet))
        passcode.delegate = self
        addChildCoordinator(childCoordinator: passcode)
        passcode.start()
    }

    func showAddressesKeys() {

    }

    func showAddressBook() {

    }

    func showLanguage() {

    }

    func showNetwork() {

    }

    func showRateApp() {

    }

    func showFeedback() {

    }

    func showSupport() {

    }

    func userSetEnabledBiometric(isOn: Bool, wallet: DomainLayer.DTO.Wallet) {
        let passcode = PasscodeCoordinator(navigationController: navigationController, kind: .setEnableBiometric(isOn, wallet: wallet))
        addChildCoordinator(childCoordinator: passcode)
        passcode.start()
    }

    func showChangePasscode(wallet: DomainLayer.DTO.Wallet) {
        let passcode = PasscodeCoordinator(navigationController: navigationController, kind: .changePasscode(wallet))
        addChildCoordinator(childCoordinator: passcode)
        passcode.start()
    }

    func showChangePassword(wallet: DomainLayer.DTO.Wallet) {

        let vc = AccountPasswordModuleBuilder(output: self).build(input: .init(wallet: wallet))
        navigationController.pushViewController(vc, animated: true)
    }

    func userLogouted() {

    }

    func useerDeteedAccount() {

    }
}


// MARK: PasscodeCoordinatorDelegate
extension ProfileCoordinator: PasscodeCoordinatorDelegate {

    func passcodeCoordinatorUserAuthorizationCompleted() {

        guard let state = state else { return }
        switch state {
        case .backupPhrase:

            let backup = BackupCoordinator(viewController: navigationController, seed: ["Test"], completed: { [weak self] needBackup in
//                self?.beginRegistration(needBackup: needBackup)
            })
            addChildCoordinator(childCoordinator: backup)
            backup.start()

        }

        self.state = nil
    }

    func passcodeCoordinatorUserLogouted() {}
}

extension ProfileCoordinator: AccountPasswordModuleOutput {
    func authorizationByPasswordCompleted(wallet: DomainLayer.DTO.Wallet, password: String) {

    }
}
