//
//  ProfileCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 04/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class ProfileCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?
    let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = ProfileModuleBuilder(output: self).build()
        self.navigationController.pushViewController(vc, animated: true)
    }
}

extension ProfileCoordinator: ProfileModuleOutput {
    func showAddressesKeys() {

    }

    func showAddressBook() {

    }

    func showLanguage() {

    }

    func showBackupPhrase() {

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
        let passcode = PasscodeCoordinator.init(navigationController: navigationController, kind: .setEnableBiometric(isOn, wallet: wallet))
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

extension ProfileCoordinator: AccountPasswordModuleOutput {
    func authorizationByPasswordCompleted(wallet: DomainLayer.DTO.Wallet, password: String) {

    }
}
