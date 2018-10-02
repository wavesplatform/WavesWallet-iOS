//
//  PasscodeCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 25/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol PasscodeCoordinatorDelegate: AnyObject {
    func userAuthorizationCompleted()
    func userLogouted()
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
            self.navigationController.popViewController(animated: true)
        }
    }
}

// MARK: PasscodeOutput
extension PasscodeCoordinator: PasscodeModuleOutput {

    func tapBackButton() {
        dissmiss()
    }

    func authorizationCompleted(passcode: String, wallet: DomainLayer.DTO.Wallet, isNewWallet: Bool) {

        if isNewWallet {
            let vc = UseTouchIDModuleBuilder(output: self).build(input: .init(passcode: passcode, wallet: wallet))
            navigationController.present(vc, animated: true, completion: nil)
        } else {
            dissmiss()
            delegate?.userAuthorizationCompleted()
        }
    }

    func userLogouted() {
        dissmiss()
        delegate?.userLogouted()
    }

    func logInByPassword() {
        if case .logIn(let wallet) = kind {
            let vc = AccountPasswordModuleBuilder(output: self).build(input: .init(wallet: wallet))
            navigationController.pushViewController(vc, animated: true)
        }
    }
}

// MARK: AccountPasswordModuleOutput
extension PasscodeCoordinator: AccountPasswordModuleOutput {
    func authorizationByPasswordCompleted() {
        dissmiss()
        delegate?.userAuthorizationCompleted()
    }
}

// MARK: UseTouchIDModuleOutput
extension PasscodeCoordinator: UseTouchIDModuleOutput {

    func userSkipRegisterBiometric() {
        dissmiss()
        delegate?.userAuthorizationCompleted()
    }

    func userRegisteredBiometric() {
        dissmiss()
        delegate?.userAuthorizationCompleted()
    }
}
