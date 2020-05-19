//
//  PasscodeCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 25/09/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import UIKit

protocol PasscodeCoordinatorDelegate: AnyObject {
    func passcodeCoordinatorAuthorizationCompleted(wallet: Wallet)
    func passcodeCoordinatorVerifyAcccesCompleted(signedWallet: SignedWallet)
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

    init(kind: PasscodeTypes.DTO.Kind, behaviorPresentation: BehaviorPresentation) {
        self.kind = kind
        self.behaviorPresentation = behaviorPresentation

        switch behaviorPresentation {
        case .modal:
            mainNavigationRouter = NavigationRouter(navigationController: CustomNavigationController())

        case let .push(router, _):
            mainNavigationRouter = router
        }
    }

    func start() {
        let vc = PasscodeModuleBuilder(output: self)
            .build(input: .init(kind: kind, hasBackButton: behaviorPresentation.isPush))

        switch behaviorPresentation {
        case let .modal(router):

            mainNavigationRouter.pushViewController(vc)
            router.present(mainNavigationRouter.navigationController, animated: true, completion: nil)

        case .push:
            mainNavigationRouter.pushViewController(vc, animated: true) { [weak self] in
                guard let self = self else { return }
                self.removeFromParentCoordinator()
            }
        }
    }

    private func dissmiss() {
        removeFromParentCoordinator()

        switch behaviorPresentation {
        case let .modal(router):
            router.dismiss(animated: true, completion: nil)

        case let .push(_, dissmissToRoot):
            if dissmissToRoot {
                mainNavigationRouter.popToRootViewController(animated: true)
            } else {
                mainNavigationRouter.popViewController()
            }
        }
    }
}

// MARK: PasscodeOutput

extension PasscodeCoordinator: PasscodeModuleOutput {
    func passcodeVerifyAccessCompleted(_ wallet: SignedWallet) {
        delegate?.passcodeCoordinatorVerifyAcccesCompleted(signedWallet: wallet)
    }

    func passcodeTapBackButton() {
        dissmiss()
    }

    func passcodeLogInCompleted(passcode: String, wallet: Wallet, isNewWallet: Bool) {
        if isNewWallet, BiometricType.enabledBiometric != .none {
            let vc = UseTouchIDModuleBuilder(output: self)
                .build(input: .init(passcode: passcode, wallet: wallet))
            mainNavigationRouter.present(vc, animated: true, completion: nil)
        } else {
            delegate?.passcodeCoordinatorAuthorizationCompleted(wallet: wallet)
            dissmiss()
        }
    }

    func passcodeUserLogouted() {
        delegate?.passcodeCoordinatorWalletLogouted()
        dissmiss()
    }

    func passcodeLogInByPassword() {
        switch kind {
        case let .verifyAccess(wallet):
            showAccountPassword(kind: .verifyAccess(wallet))

        case let .logIn(wallet):
            showAccountPassword(kind: .logIn(wallet))

        case let .changePasscode(wallet):
            showAccountPassword(kind: .verifyAccess(wallet))

        case let .setEnableBiometric(_, wallet):
            showAccountPassword(kind: .verifyAccess(wallet))

        case let .changePassword(wallet, _, _):
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
    func accountPasswordVerifyAccess(signedWallet: SignedWallet, password: String) {
        let vc = PasscodeModuleBuilder(output: self)
            .build(input: .init(kind: .changePasscodeByPassword(signedWallet.wallet,
                                                                password: password),
                                hasBackButton: true))
        mainNavigationRouter.pushViewController(vc)
    }

    func accountPasswordAuthorizationCompleted(wallet: Wallet, password: String) {
        let vc = PasscodeModuleBuilder(output: self)
            .build(input: .init(kind: .changePasscodeByPassword(wallet,
                                                                password: password),
                                hasBackButton: true))

        mainNavigationRouter.pushViewController(vc)
    }
}

// MARK: UseTouchIDModuleOutput

extension PasscodeCoordinator: UseTouchIDModuleOutput {
    func userSkipRegisterBiometric(wallet: Wallet) {
        mainNavigationRouter.dismiss(animated: true, completion: nil)
        delegate?.passcodeCoordinatorAuthorizationCompleted(wallet: wallet)
        dissmiss()
    }

    func userRegisteredBiometric(wallet: Wallet) {
        mainNavigationRouter.dismiss(animated: true, completion: nil)
        delegate?.passcodeCoordinatorAuthorizationCompleted(wallet: wallet)
        dissmiss()
    }
}
