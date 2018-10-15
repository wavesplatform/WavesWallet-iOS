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

        self.state = .backupPhrase(completed: completed)        
        let passcode = PasscodeCoordinator(navigationController: navigationController, kind: .verifyAccess(wallet))
        passcode.delegate = self
        addChildCoordinator(childCoordinator: passcode)
        passcode.start()
    }

    func showAddressesKeys() {
        navigationController.presentBasicAlertWithTitle(title: "🐙")
    }

    func showAddressBook() {
        let vc = AddressBookModuleBuilder.init(output: nil).build(input: .init(isEditMode: false))
        self.navigationController.pushViewController(vc, animated: true)
    }

    func showLanguage() {
        let language = StoryboardScene.Language.languageViewController.instantiate()
        language.delegate = self
        navigationController.pushViewController(language, animated: true)
    }

    func showNetwork() {
        navigationController.presentBasicAlertWithTitle(title: "🐙")
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
        navigationController.presentBasicAlertWithTitle(title: "🐙")
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

        guard let state = state else { return }
        switch state {
        case .backupPhrase(let completed):

            let seed = signedWallet.seed.seed.split(separator: " ").map { "\($0)" }

            let backup = BackupCoordinator(navigationController: navigationController, seed: seed, completed: { [weak self] needBackup in
                completed(!needBackup)
                self?.navigationController.popToRootViewController(animated: true)
            })
            addChildCoordinator(childCoordinator: backup)
            backup.start()
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
