//
//  AddressesKeysCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 27/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class AddressesKeysCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    private let navigationController: UINavigationController
    private let wallet: DomainLayer.DTO.Wallet
    private var needPrivateKeyCallback: ((DomainLayer.DTO.SignedWallet) -> Void)?
    private var rootViewController: UIViewController?

    private var currentPopup: PopupViewController?

    init(navigationController: UINavigationController, wallet: DomainLayer.DTO.Wallet) {
        self.navigationController = navigationController
        self.wallet = wallet
    }

    func start() {
        let vc = AddressesKeysModuleBuilder(output: self).build(input: .init(wallet: wallet))
        self.rootViewController = vc
        self.navigationController.pushViewController(vc, animated: true)
    }

    private func showPasscode(wallet: DomainLayer.DTO.Wallet) {

        let passcodeCoordinator = PasscodeCoordinator(navigationController: navigationController,
                                                      kind: .verifyAccess(wallet))
        passcodeCoordinator.animated = true
        passcodeCoordinator.delegate = self
        passcodeCoordinator.isDontClose = true

        addChildCoordinator(childCoordinator: passcodeCoordinator)
        passcodeCoordinator.start()
    }
}

// MARK: PasscodeCoordinatorDelegate

extension AddressesKeysCoordinator: PasscodeCoordinatorDelegate {

    func passcodeCoordinatorAuthorizationCompleted(wallet: DomainLayer.DTO.Wallet) {}

    func passcodeCoordinatorVerifyAcccesCompleted(signedWallet: DomainLayer.DTO.SignedWallet) {
        if let callback = self.needPrivateKeyCallback {
            callback(signedWallet)
            self.needPrivateKeyCallback = nil
            if let rootViewController = self.rootViewController {
                navigationController.popToViewController(rootViewController, animated: true)
            }
            childCoordinators.last(where: { $0 is PasscodeCoordinator })?.removeFromParentCoordinator()
        }
    }

    func passcodeCoordinatorWalletLogouted() {}
}

// MARK: AddressesKeysModuleOutput

extension AddressesKeysCoordinator: AddressesKeysModuleOutput {

    func addressesKeysShowAliases(_ aliases: [DomainLayer.DTO.Alias]) {

        if aliases.count == 0 {
            let controller = StoryboardScene.Profile.aliasWithoutViewController.instantiate()
            controller.delegate = self
            let popup = PopupViewController()
            popup.contentHeight = 378
            popup.present(contentViewController: controller)
            self.currentPopup = popup
        } else {
            let controller = AliasesModuleBuilder.init(output: self).build(input: .init(aliases: aliases))
            let popup = PopupViewController()            
            popup.present(contentViewController: controller)
            self.currentPopup = popup
        }
    }

    func addressesKeysNeedPrivateKey(wallet: DomainLayer.DTO.Wallet, callback: @escaping ((DomainLayer.DTO.SignedWallet) -> Void)) {
        self.needPrivateKeyCallback = callback
        showPasscode(wallet: wallet)
    }
}

// MARK: AliasesModuleOutput

extension AddressesKeysCoordinator: AliasesModuleOutput {
    func aliasesCreateAlias() {

        self.currentPopup?.dismissPopup {
            let vc = CreateAliasModuleBuilder(output: self).build()
            self.navigationController.pushViewController(vc, animated: true)
        }
    }
}

// MARK: AliasWithoutViewControllerDelegate

extension AddressesKeysCoordinator: AliasWithoutViewControllerDelegate {
    func aliasWithoutUserTapCreateNewAlias() {
        self.currentPopup?.dismissPopup {
            let vc = CreateAliasModuleBuilder(output: self).build()
            self.navigationController.pushViewController(vc, animated: true)
        }
    }
}

// MARK: CreateAliasModuleOutput

extension AddressesKeysCoordinator: CreateAliasModuleOutput {
    func createAliasCompletedCreateAlias(_ alias: String) {
        if let rootViewController = self.rootViewController {
            navigationController.popToViewController(rootViewController, animated: true)
        }
    }
}


