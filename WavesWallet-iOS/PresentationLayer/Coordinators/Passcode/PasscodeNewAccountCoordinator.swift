//
//  PasscodeNewAccountCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 20/12/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

//protocol PasscodeCoordinatorDelegate: AnyObject {
//    func passcodeCoordinatorAuthorizationCompleted(wallet: DomainLayer.DTO.Wallet)
//    func passcodeCoordinatorVerifyAcccesCompleted(signedWallet: DomainLayer.DTO.SignedWallet)
//    func passcodeCoordinatorWalletLogouted()
//}

final class PasscodeNewAccountCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    private let navigationRouter: NavigationRouter

    private let account: PasscodeTypes.DTO.Account

    weak var delegate: PasscodeCoordinatorDelegate?

    init(navigationRouter: NavigationRouter, account: PasscodeTypes.DTO.Account) {

        self.navigationRouter = navigationRouter
        self.account = account
    }

    func start() {

        let vc = PasscodeModuleBuilder(output: self)
            .build(input: .init(kind: .registration(account),
                                hasBackButton: true))


        navigationRouter.pushViewController(vc, animated: true) { [weak self] in
            self?.removeFromParentCoordinator()
        }
//        navigationController.pushViewController(vc, animated: true)
//
//        if hasExternalNavigationController == false {
//            if let presentedViewController = viewController.presentedViewController {
//                presentedViewController.present(navigationController, animated: true, completion: nil)
//            } else {
//                viewController.present(navigationController, animated: animated, completion: nil)
//            }
//        }
    }

    private func dissmiss() {
//        removeFromParentCoordinator()

//        if hasExternalNavigationController == false {
//            self.viewController.dismiss(animated: true, completion: nil)
//        } else {
//            if isDontToRoot == true {
//                self.navigationController.popViewController(animated: true)
//            } else {
//                self.navigationController.popToRootViewController(animated: true)
//            }
//        }
    }
}

// MARK: PasscodeOutput
extension PasscodeNewAccountCoordinator: PasscodeModuleOutput {

    func passcodeVerifyAccessCompleted(_ wallet: DomainLayer.DTO.SignedWallet) {
        delegate?.passcodeCoordinatorVerifyAcccesCompleted(signedWallet: wallet)
    }

    func passcodeTapBackButton() {
        dissmiss()
    }

    func passcodeLogInCompleted(passcode: String, wallet: DomainLayer.DTO.Wallet, isNewWallet: Bool) {

        if isNewWallet, BiometricType.enabledBiometric != .none {
            let vc = UseTouchIDModuleBuilder(output: self).build(input: .init(passcode: passcode, wallet: wallet))
//            navigationController.present(vc, animated: true, completion: nil)
        } else {
            dissmiss()
            delegate?.passcodeCoordinatorAuthorizationCompleted(wallet: wallet)
        }
    }

    func passcodeUserLogouted() {
        delegate?.passcodeCoordinatorWalletLogouted()
        dissmiss()
    }

    func passcodeLogInByPassword() {

//        switch kind {
//        case .verifyAccess(let wallet):
//            showAccountPassword(kind: .verifyAccess(wallet))
//
//        case .logIn(let wallet):
//            showAccountPassword(kind: .logIn(wallet))
//
//        case .changePasscode(let wallet):
//            showAccountPassword(kind: .verifyAccess(wallet))
//
//        case .setEnableBiometric(_, let wallet):
//            showAccountPassword(kind: .verifyAccess(wallet))
//
//        case .changePassword(let wallet, _, _):
//            showAccountPassword(kind: .verifyAccess(wallet))
//
//        default:
//            break
//        }
    }

    func showAccountPassword(kind: AccountPasswordTypes.DTO.Kind) {

        let vc = AccountPasswordModuleBuilder(output: self)
            .build(input: .init(kind: kind))
//        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: AccountPasswordModuleOutput
extension PasscodeNewAccountCoordinator: AccountPasswordModuleOutput {

    func accountPasswordVerifyAccess(signedWallet: DomainLayer.DTO.SignedWallet, password: String) {

        let vc = PasscodeModuleBuilder(output: self)
            .build(input: .init(kind: .changePasscodeByPassword(signedWallet.wallet,
                                                                password: password),
                                hasBackButton: true))

//        navigationController.pushViewController(vc, animated: true)
    }

    func accountPasswordAuthorizationCompleted(wallet: DomainLayer.DTO.Wallet, password: String) {

        let vc = PasscodeModuleBuilder(output: self)
            .build(input: .init(kind: .changePasscodeByPassword(wallet,
                                                                password: password),
                                hasBackButton: true))

//        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: UseTouchIDModuleOutput
extension PasscodeNewAccountCoordinator: UseTouchIDModuleOutput {

    func userSkipRegisterBiometric(wallet: DomainLayer.DTO.Wallet) {

        dissmiss()
        delegate?.passcodeCoordinatorAuthorizationCompleted(wallet: wallet)
    }

    func userRegisteredBiometric(wallet: DomainLayer.DTO.Wallet) {

        dissmiss()
        delegate?.passcodeCoordinatorAuthorizationCompleted(wallet: wallet)
    }
}
