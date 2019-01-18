//
//  ProfileCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 04/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift
import StoreKit
import MessageUI

private enum Constants {
    static let supporURL = URL(string: "https://support.wavesplatform.com/")!
    static let supportEmail = "support@wavesplatform.com"
}

final class ProfileCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?
    private weak var applicationCoordinator: ApplicationCoordinatorProtocol?

    private let authorization = FactoryInteractors.instance.authorization

    private let navigationRouter: NavigationRouter
    private let disposeBag: DisposeBag = DisposeBag()

    init(navigationRouter: NavigationRouter, applicationCoordinator: ApplicationCoordinatorProtocol?) {
        self.applicationCoordinator = applicationCoordinator
        self.navigationRouter = navigationRouter
    }

    func start() {
        let vc = ProfileModuleBuilder(output: self).build()

        self.navigationRouter.pushViewController(vc, animated: true) { [weak self] in
            self?.removeFromParentCoordinator()
        }
        setupBackupTost(target: vc, navigationRouter: navigationRouter, disposeBag: disposeBag)
    }
}

// MARK: ProfileModuleOutput

extension ProfileCoordinator: ProfileModuleOutput {

    func showBackupPhrase(wallet: DomainLayer.DTO.Wallet, saveBackedUp: @escaping ((_ isBackedUp: Bool) -> Void)) {

        authorization
            .authorizedWallet()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (signedWallet) in

                guard let owner = self else { return }

                let seed = signedWallet.seedWords

                if wallet.isBackedUp == false {
                    
                    let backup = BackupCoordinator(seed: seed,
                                                   behaviorPresentation: .push(owner.navigationRouter),
                                                   hasShowNeedBackupView: false,
                                                   completed: { isSkipBackup in
                        saveBackedUp(!isSkipBackup)
                    })
                    owner.addChildCoordinatorAndStart(childCoordinator: backup)
                } else {
                    let vc = StoryboardScene.Backup.saveBackupPhraseViewController.instantiate()
                    vc.input = .init(seed: seed, isReadOnly: true)
                    owner.navigationRouter.pushViewController(vc)
                }
            })
            .disposed(by: disposeBag)
    }

    func showAddressesKeys(wallet: DomainLayer.DTO.Wallet) {
        guard let applicationCoordinator = self.applicationCoordinator else { return }

        let coordinator = AddressesKeysCoordinator(navigationRouter: navigationRouter,
                                                   wallet: wallet,
                                                   applicationCoordinator: applicationCoordinator)
        addChildCoordinatorAndStart(childCoordinator: coordinator)
    }

    func showAddressBook() {
        let vc = AddressBookModuleBuilder(output: nil)
            .build(input: .init(isEditMode: true))
        navigationRouter.pushViewController(vc)
    }

    func showLanguage() {
        let language = StoryboardScene.Language.languageViewController.instantiate()
        language.delegate = self
        navigationRouter.pushViewController(language)
    }

    func showNetwork(wallet: DomainLayer.DTO.Wallet) {
        let vc = NetworkSettingsModuleBuilder(output: self)
            .build(input: .init(wallet: wallet))
        navigationRouter.pushViewController(vc)
    }

    func showRateApp() {
        RateApp.show()
    }

    func showFeedback() {
        let coordinator = MailComposeCoordinator(viewController: navigationRouter.navigationController, email: Constants.supportEmail)
        addChildCoordinator(childCoordinator: coordinator)
        coordinator.start()
    }

    func showSupport() {
        UIApplication.shared.openURLAsync(Constants.supporURL)
    }

    func showAlertForEnabledBiometric() {

        let alertController = UIAlertController (title: Localizable.Waves.Profile.Alert.Setupbiometric.title,
                                                 message: Localizable.Waves.Profile.Alert.Setupbiometric.message,
                                                 preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: Localizable.Waves.Profile.Alert.Setupbiometric.Button.settings, style: .default) { (_) -> Void in
            
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            guard UIApplication.shared.canOpenURL(settingsUrl) else { return }

            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
        }

        let cancelAction = UIAlertAction(title: Localizable.Waves.Profile.Alert.Setupbiometric.Button.cancel, style: .cancel, handler: nil)

        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)

        navigationRouter.present(alertController)
    }

    func accountSetEnabledBiometric(isOn: Bool, wallet: DomainLayer.DTO.Wallet) {
        let passcode = PasscodeCoordinator(kind: .setEnableBiometric(isOn, wallet: wallet),
                                           behaviorPresentation: .push(navigationRouter, dissmissToRoot: true))
        passcode.delegate = self
        addChildCoordinatorAndStart(childCoordinator: passcode)
    }

    func showChangePasscode(wallet: DomainLayer.DTO.Wallet) {
        let passcode = PasscodeCoordinator(kind: .changePasscode(wallet),
                                           behaviorPresentation: .push(navigationRouter, dissmissToRoot: true))

        passcode.delegate = self
        addChildCoordinatorAndStart(childCoordinator: passcode)
    }

    func showChangePassword(wallet: DomainLayer.DTO.Wallet) {
        let vc = ChangePasswordModuleBuilder(output: self)
            .build(input: .init(wallet: wallet))
        navigationRouter.pushViewController(vc)
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

    func passcodeCoordinatorWalletLogouted() {
        applicationCoordinator?.showEnterDisplay()
    }

    func passcodeCoordinatorVerifyAcccesCompleted(signedWallet: DomainLayer.DTO.SignedWallet) {}
}

// MARK: LanguageViewControllerDelegate

extension ProfileCoordinator: LanguageViewControllerDelegate {
    func languageViewChangedLanguage() {
        navigationRouter.popViewController()
    }
}

// MARK: ChangePasswordModuleOutput

extension ProfileCoordinator: ChangePasswordModuleOutput {
    func changePasswordCompleted(wallet: DomainLayer.DTO.Wallet, newPassword: String, oldPassword: String) {

        let passcode = PasscodeCoordinator(kind: .changePassword(wallet: wallet,
                                                                 newPassword: newPassword,
                                                                 oldPassword: oldPassword),
                                           behaviorPresentation: .push(navigationRouter, dissmissToRoot: true))

        passcode.delegate = self
        addChildCoordinatorAndStart(childCoordinator: passcode)        
    }
}

// MARK: NetworkSettingsModuleOutput

extension ProfileCoordinator: NetworkSettingsModuleOutput {

    func networkSettingSavedSetting() {
        NotificationCenter.default.post(name: .changedSpamList, object: nil)
        navigationRouter.popViewController()
    }
}


