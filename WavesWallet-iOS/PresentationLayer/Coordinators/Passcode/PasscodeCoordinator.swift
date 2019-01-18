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

    enum BehaviorPresentation {
        case push(NavigationRouter, dissmissToRoot: Bool)
        case modal(Router)

        var isPush: Bool {
            switch self {
            case .push:
                return true

            default:
                return false
            }
        }
    }

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    private let mainNavigationRouter: NavigationRouter

    private let kind: PasscodeTypes.DTO.Kind
    private let behaviorPresentation: BehaviorPresentation


    weak var delegate: PasscodeCoordinatorDelegate?

    init(kind: PasscodeTypes.DTO.Kind, behaviorPresentation: BehaviorPresentation)  {
        self.kind = kind
        self.behaviorPresentation = behaviorPresentation

        switch behaviorPresentation {
        case .modal:
            mainNavigationRouter = NavigationRouter(navigationController: CustomNavigationController())

        case .push(let router, _):
            mainNavigationRouter = router
        }
    }

    func start() {

        let vc = PasscodeModuleBuilder(output: self)
            .build(input: .init(kind: kind, hasBackButton: behaviorPresentation.isPush))

        switch behaviorPresentation {
        case .modal(let router):

            mainNavigationRouter.pushViewController(vc)
            router.present(mainNavigationRouter.navigationController, animated: true, completion: nil)

        case .push:
            mainNavigationRouter.pushViewController(vc, animated: true) { [weak self] in
                self?.removeFromParentCoordinator()
            }
        }
    }

    private func dissmiss() {
        removeFromParentCoordinator()

        switch behaviorPresentation {
        case .modal(let router):
            router.dismiss(animated: true, completion: nil)

        case .push(_, let dissmissToRoot):
            if dissmissToRoot {
                self.mainNavigationRouter.popToRootViewController(animated: true)
            } else {
                self.mainNavigationRouter.popViewController()
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

        if isNewWallet, BiometricType.enabledBiometric != .none {
            let vc = UseTouchIDModuleBuilder(output: self)
                .build(input: .init(passcode: passcode, wallet: wallet))
            mainNavigationRouter.present(vc, animated: true, completion: nil)
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

        switch kind {
        case .verifyAccess(let wallet):
            showAccountPassword(kind: .verifyAccess(wallet))

        case .logIn(let wallet):
            showAccountPassword(kind: .logIn(wallet))

        case .changePasscode(let wallet):
            showAccountPassword(kind: .verifyAccess(wallet))

        case .setEnableBiometric(_, let wallet):
            showAccountPassword(kind: .verifyAccess(wallet))

        case .changePassword(let wallet, _, _):
            showAccountPassword(kind: .verifyAccess(wallet))

        default:
            break
        }
    }

    func showAccountPassword(kind: AccountPasswordTypes.DTO.Kind) {

        let vc = AccountPasswordModuleBuilder(output: self)
            .build(input: .init(kind: kind))
        mainNavigationRouter.pushViewController(vc)
    }
}

// MARK: AccountPasswordModuleOutput
extension PasscodeCoordinator: AccountPasswordModuleOutput {

    func accountPasswordVerifyAccess(signedWallet: DomainLayer.DTO.SignedWallet, password: String) {

        let vc = PasscodeModuleBuilder(output: self)
            .build(input: .init(kind: .changePasscodeByPassword(signedWallet.wallet,
                                                                password: password),
                                hasBackButton: true))
        mainNavigationRouter.pushViewController(vc)
    }

    func accountPasswordAuthorizationCompleted(wallet: DomainLayer.DTO.Wallet, password: String) {

        let vc = PasscodeModuleBuilder(output: self)
            .build(input: .init(kind: .changePasscodeByPassword(wallet,
                                                                password: password),
                                hasBackButton: true))

        mainNavigationRouter.pushViewController(vc)
    }
}

// MARK: UseTouchIDModuleOutput
extension PasscodeCoordinator: UseTouchIDModuleOutput {

    func userSkipRegisterBiometric(wallet: DomainLayer.DTO.Wallet) {

        mainNavigationRouter.dismiss(animated: true, completion: nil)
        dissmiss()
        delegate?.passcodeCoordinatorAuthorizationCompleted(wallet: wallet)
    }

    func userRegisteredBiometric(wallet: DomainLayer.DTO.Wallet) {

        mainNavigationRouter.dismiss(animated: true, completion: nil)
        dissmiss()
        delegate?.passcodeCoordinatorAuthorizationCompleted(wallet: wallet)
    }
}
