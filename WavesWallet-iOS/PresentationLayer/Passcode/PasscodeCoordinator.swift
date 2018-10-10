//
//  PasscodeCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 25/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol PasscodeCoordinatorDelegate: AnyObject {
    func passcodeCoordinatorUserAuthorizationCompleted()
    func passcodeCoordinatorUserLogouted()
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
            self.navigationController.popToRootViewController(animated: true)
        }
    }
}

// MARK: PasscodeOutput
extension PasscodeCoordinator: PasscodeModuleOutput {

    func passcodeTapBackButton() {
        dissmiss()
    }

    func passcodeLogInCompleted(passcode: String, wallet: DomainLayer.DTO.Wallet, isNewWallet: Bool) {

        if isNewWallet {
            let vc = UseTouchIDModuleBuilder(output: self).build(input: .init(passcode: passcode, wallet: wallet))
            navigationController.present(vc, animated: true, completion: nil)
        } else {
            dissmiss()
            delegate?.passcodeCoordinatorUserAuthorizationCompleted()
        }
    }

    func passcodeUserLogouted() {
        dissmiss()
        delegate?.passcodeCoordinatorUserLogouted()
    }

    func passcodeLogInByPassword() {
        if case .logIn(let wallet) = kind {
            showAccountPassword(wallet: wallet)
        } else if case .changePasscode(let wallet) = kind {
            showAccountPassword(wallet: wallet)
        }
    }

    func showAccountPassword(wallet: DomainLayer.DTO.Wallet) {
        let vc = AccountPasswordModuleBuilder(output: self).build(input: .init(wallet: wallet))
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: AccountPasswordModuleOutput
extension PasscodeCoordinator: AccountPasswordModuleOutput {
    func authorizationByPasswordCompleted(wallet: DomainLayer.DTO.Wallet, password: String) {

        if case .changePasscode(let wallet) = kind {
            let vc = PasscodeModuleBuilder(output: self)
                .build(input: .init(kind: .changePasscodeByPassword(wallet, password: password),
                                    hasBackButton: hasExternalNavigationController))
            navigationController.pushViewController(vc, animated: true)
        } else {
            dissmiss()
            delegate?.passcodeCoordinatorUserAuthorizationCompleted()
        }
    }
}

// MARK: UseTouchIDModuleOutput
extension PasscodeCoordinator: UseTouchIDModuleOutput {

    func userSkipRegisterBiometric() {
        dissmiss()
        delegate?.passcodeCoordinatorUserAuthorizationCompleted()
    }

    func userRegisteredBiometric() {
        dissmiss()
        delegate?.passcodeCoordinatorUserAuthorizationCompleted()
    }
}
