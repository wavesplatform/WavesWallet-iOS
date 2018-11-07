//
//  PasscodeCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 25/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol PasscodeCoordinatorDelegate: AnyObject {
    func passcodeCoordinatorAuthorizationCompleted(wallet: DomainLayer.DTO.Wallet)
    func passcodeCoordinatorVerifyAcccesCompleted(signedWallet: DomainLayer.DTO.SignedWallet)
    func passcodeCoordinatorWalletLogouted()
}

final class PasscodeCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    private let viewController: UIViewController
    private let navigationController: UINavigationController

    private let hasExternalNavigationController: Bool
    private let kind: PasscodeTypes.DTO.Kind
    
    weak var delegate: PasscodeCoordinatorDelegate?
    var animated: Bool = true
    var isDontToRoot: Bool = false

    init(viewController: UIViewController, kind: PasscodeTypes.DTO.Kind) {

        self.viewController = viewController
        self.navigationController = CustomNavigationController()
        self.kind = kind
        self.hasExternalNavigationController = false
    }

    init(navigationController: UINavigationController, kind: PasscodeTypes.DTO.Kind) {
        self.viewController = navigationController
        self.navigationController = navigationController
        self.kind = kind
        self.hasExternalNavigationController = true
    }

    func start() {

        let vc = PasscodeModuleBuilder(output: self)
            .build(input: .init(kind: kind, hasBackButton: hasExternalNavigationController))
        
        navigationController.pushViewController(vc, animated: true)

        if hasExternalNavigationController == false {
            if let presentedViewController = viewController.presentedViewController {
                presentedViewController.present(navigationController, animated: true, completion: nil)
            } else {
                viewController.present(navigationController, animated: animated, completion: nil)
            }
        }
    }

    private func dissmiss() {
        removeFromParentCoordinator()

        if hasExternalNavigationController == false {
            self.viewController.dismiss(animated: true, completion: nil)
        } else {
            if isDontToRoot == true {
                self.navigationController.popViewController(animated: true)
            } else {
                self.navigationController.popToRootViewController(animated: true)
            }
        }
    }
}

// MARK: PasscodeOutput
extension PasscodeCoordinator: PasscodeModuleOutput {

    func passcodeVerifyAccessCompleted(_ wallet: DomainLayer.DTO.SignedWallet) {
        delegate?.passcodeCoordinatorVerifyAcccesCompleted(signedWallet: wallet)
    }

    func passcodeTapBackButton() {
        dissmiss()
    }

    func passcodeLogInCompleted(passcode: String, wallet: DomainLayer.DTO.Wallet, isNewWallet: Bool) {

        if isNewWallet {
            let vc = UseTouchIDModuleBuilder(output: self).build(input: .init(passcode: passcode, wallet: wallet))
            navigationController.present(vc, animated: true, completion: nil)
        } else {
            dissmiss()
            delegate?.passcodeCoordinatorAuthorizationCompleted(wallet: wallet)
        }
    }

    func passcodeUserLogouted() {
        dissmiss()
        delegate?.passcodeCoordinatorWalletLogouted()
    }

    func passcodeLogInByPassword() {
        if case .logIn(let wallet) = kind {
            showAccountPassword(kind: .logIn(wallet))
        } else if case .changePasscode(let wallet) = kind {
            showAccountPassword(kind: .logIn(wallet))
        } else if case .verifyAccess(let wallet) = kind {
            showAccountPassword(kind: .verifyAccess(wallet))
        }
    }

    func showAccountPassword(kind: AccountPasswordTypes.DTO.Kind) {

        let vc = AccountPasswordModuleBuilder(output: self)
            .build(input: .init(kind: kind))
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: AccountPasswordModuleOutput
extension PasscodeCoordinator: AccountPasswordModuleOutput {

    func accountPasswordVerifyAccess(signedWallet: DomainLayer.DTO.SignedWallet, password: String) {

        let vc = PasscodeModuleBuilder(output: self)
            .build(input: .init(kind: .changePasscodeByPassword(signedWallet.wallet,
                                                                password: password),
                                hasBackButton: true))

        navigationController.pushViewController(vc, animated: true)
    }

    func accountPasswordAuthorizationCompleted(wallet: DomainLayer.DTO.Wallet, password: String) {

        let vc = PasscodeModuleBuilder(output: self)
            .build(input: .init(kind: .changePasscodeByPassword(wallet,
                                                                password: password),
                                hasBackButton: true))

        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: UseTouchIDModuleOutput
extension PasscodeCoordinator: UseTouchIDModuleOutput {

    func userSkipRegisterBiometric(wallet: DomainLayer.DTO.Wallet) {

        dissmiss()
        delegate?.passcodeCoordinatorAuthorizationCompleted(wallet: wallet)
    }

    func userRegisteredBiometric(wallet: DomainLayer.DTO.Wallet) {

        dissmiss()
        delegate?.passcodeCoordinatorAuthorizationCompleted(wallet: wallet)
    }
}
