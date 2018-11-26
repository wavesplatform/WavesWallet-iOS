//
//  ProfileCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 04/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import StoreKit
import MessageUI

private enum Constants {
    static let supporURL = URL(string: "https://support.wavesplatform.com/")!
    static let supportEmail = "mobileapp@wavesplatform.com"
}

private enum State {
    case backupPhrase(completed: ((_ isBackedUp: Bool) -> Void))
    case showPhrase
}

final class ProfileCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?
    private weak var applicationCoordinator: ApplicationCoordinatorProtocol?

    private let navigationController: UINavigationController
    private var state: State?

    init(navigationController: UINavigationController, applicationCoordinator: ApplicationCoordinatorProtocol?) {
        self.applicationCoordinator = applicationCoordinator
        self.navigationController = navigationController
    }

    func start() {
        let vc = ProfileModuleBuilder(output: self).build()
        self.navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: ProfileModuleOutput

extension ProfileCoordinator: ProfileModuleOutput {

    func showBackupPhrase(wallet: DomainLayer.DTO.Wallet, completed: @escaping ((_ isBackedUp: Bool) -> Void)) {

        if wallet.isBackedUp == true {
            self.state = .showPhrase
        } else {
            self.state = .backupPhrase(completed: completed)
        }

        let passcode = PasscodeCoordinator(navigationController: navigationController, kind: .verifyAccess(wallet))
        passcode.delegate = self
        addChildCoordinator(childCoordinator: passcode)
        passcode.start()
    }

    func showAddressesKeys(wallet: DomainLayer.DTO.Wallet) {

        let coordinator = AddressesKeysCoordinator(navigationController: navigationController, wallet: wallet)
        addChildCoordinator(childCoordinator: coordinator)
        coordinator.start()
    }

    func showAddressBook() {
        let vc = AddressBookModuleBuilder.init(output: nil).build(input: .init(isEditMode: true))
        self.navigationController.pushViewController(vc, animated: true)
    }

    func showLanguage() {
        let language = StoryboardScene.Language.languageViewController.instantiate()
        language.delegate = self
        navigationController.pushViewController(language, animated: true)
    }

    func showNetwork(wallet: DomainLayer.DTO.Wallet) {
        let vc = NetworkSettingsModuleBuilder(output: self).build(input: .init(wallet: wallet))
        navigationController.pushViewController(vc, animated: true)
    }

    func showRateApp() {
        RateApp.show()
    }

    func showFeedback() {

        let coordinator = MailComposeCoordinator(viewController: navigationController, email: Constants.supportEmail)
        addChildCoordinator(childCoordinator: coordinator)
        coordinator.start()
    }

    func showSupport() {
        UIApplication.shared.openURLAsync(Constants.supporURL)
    }

    func accountSetEnabledBiometric(isOn: Bool, wallet: DomainLayer.DTO.Wallet) {
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
        let vc = ChangePasswordModuleBuilder(output: self).build(input: .init(wallet: wallet))
        self.navigationController.pushViewController(vc, animated: true)
    }

    func accountLogouted() {
        self.applicationCoordinator?.showEnterDisplay()
    }

    func accountDeleted() {
        self.applicationCoordinator?.showEnterDisplay()
    }
}

// MARK: PasscodeCoordinatorDelegate

extension ProfileCoordinator: PasscodeCoordinatorDelegate {

    func passcodeCoordinatorAuthorizationCompleted(wallet: DomainLayer.DTO.Wallet) {}

    func passcodeCoordinatorWalletLogouted() {}

    func passcodeCoordinatorVerifyAcccesCompleted(signedWallet: DomainLayer.DTO.SignedWallet) {

        let seed = signedWallet.seedWords

        guard let state = state else { return }
        switch state {
        case .backupPhrase(let completed):

            let backup = BackupCoordinator(navigationController: navigationController, seed: seed, completed: { [weak self] needBackup in
                completed(!needBackup)
                self?.navigationController.popToRootViewController(animated: true)
            })
            addChildCoordinator(childCoordinator: backup)
            backup.start()
        case .showPhrase:

            let viewControllers = navigationController.viewControllers.filter({ ($0 is PasscodeViewController) == false })
            navigationController.viewControllers = viewControllers
            let vc = StoryboardScene.Backup.saveBackupPhraseViewController.instantiate()
            vc.input = .init(seed: seed, isReadOnly: true)
            navigationController.pushViewController(vc, animated: true)
        }


        self.state = nil
    }
}

// MARK: LanguageViewControllerDelegate

extension ProfileCoordinator: LanguageViewControllerDelegate {
    func languageViewChangedLanguage() {
        navigationController.popViewController(animated: true)
    }
}

// MARK: ChangePasswordModuleOutput

extension ProfileCoordinator: ChangePasswordModuleOutput {
    func changePasswordCompleted(wallet: DomainLayer.DTO.Wallet, newPassword: String, oldPassword: String) {
        let passcode = PasscodeCoordinator(navigationController: navigationController,
                                           kind: .changePassword(wallet: wallet,
                                                                 newPassword: newPassword,
                                                                 oldPassword: oldPassword))
        addChildCoordinator(childCoordinator: passcode)
        passcode.start()
    }
}

// MARK: NetworkSettingsModuleOutput

extension ProfileCoordinator: NetworkSettingsModuleOutput {

    func networkSettingSavedSetting() {
        NotificationCenter.default.post(name: .changedSpamList, object: nil)
        navigationController.popViewController(animated: true)
    }
}


