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
        navigationController.presentBasicAlertWithTitle(title: "🐙")
    }

    func showNetwork() {
        navigationController.presentBasicAlertWithTitle(title: "🐙")
    }

    func showRateApp() {
        //TODO Fifx Request Review
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            DispatchQueue.main.async {
                guard let url = URL(string: "https://itunes.apple.com/us/app/waves-wallet/id1233158971?mt=8") else { return }
                UIApplication.shared.openURL(url)
            }
        }
    }

    func showFeedback() {

        let coordinator = MailComposeCoordinator(viewController: navigationController, email: "mobileapp@wavesplatform.com")
        addChildCoordinator(childCoordinator: coordinator)
        coordinator.start()
    }

    func showSupport() {

        DispatchQueue.main.async {
            guard let url = URL(string: "https://support.wavesplatform.com/") else { return }
            UIApplication.shared.openURL(url)
        }
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
        navigationController.presentBasicAlertWithTitle(title: "🐙")
//        let vc = AccountPasswordModuleBuilder(output: self).build(input: .init(wallet: wallet))
//        navigationController.pushViewController(vc, animated: true)
    }

    func userLogouted() {
        self.applicationCoordinator?.showEnterDisplay()
    }

    func useerDeteedAccount() {
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
