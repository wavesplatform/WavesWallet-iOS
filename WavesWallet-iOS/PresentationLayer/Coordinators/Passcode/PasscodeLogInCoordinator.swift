//
//  PasscodeLogInCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 24/12/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

protocol PasscodeLogInCoordinatorDelegate: AnyObject {
    func passcodeCoordinatorLogInCompleted(wallet: DomainLayer.DTO.Wallet)
    func passcodeCoordinatorWalletLogouted()
}

final class PasscodeLogInCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    private let windowRouter: WindowRouter
    private let passcodeNavigationRouter: NavigationRouter
    private let wallet: DomainLayer.DTO.Wallet

    weak var delegate: PasscodeLogInCoordinatorDelegate?

    init(wallet: DomainLayer.DTO.Wallet) {
        let window = UIWindow()
        window.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
        self.windowRouter = WindowRouter(window: window)
        self.wallet = wallet
        self.passcodeNavigationRouter = NavigationRouter(navigationController: CustomNavigationController())
    }

    func start() {

        let vc = PasscodeModuleBuilder(output: self)
            .build(input: .init(kind: .logIn(wallet),
                                hasBackButton: false))

        passcodeNavigationRouter.pushViewController(vc)

        windowRouter.setRootViewController(passcodeNavigationRouter.navigationController)
    }

    private func dissmiss() {
        windowRouter.dissmissWindow(animated: nil, completed: { [weak self] in
            self?.removeFromParentCoordinator()
        })
    }

    deinit {
        print("DEALLOC PASSCODE")
    }
}

// MARK: PasscodeOutput
extension PasscodeLogInCoordinator: PasscodeModuleOutput {

    func passcodeVerifyAccessCompleted(_ wallet: DomainLayer.DTO.SignedWallet) {}

    func passcodeTapBackButton() {
        dissmiss()
    }

    func passcodeLogInCompleted(passcode: String, wallet: DomainLayer.DTO.Wallet, isNewWallet: Bool) {
        delegate?.passcodeCoordinatorLogInCompleted(wallet: wallet)
        dissmiss()
    }

    func passcodeUserLogouted() {
        delegate?.passcodeCoordinatorWalletLogouted()
        dissmiss()
    }

    func passcodeLogInByPassword() {
        showAccountPassword(kind: .logIn(self.wallet))
    }

    func showAccountPassword(kind: AccountPasswordTypes.DTO.Kind) {

        let vc = AccountPasswordModuleBuilder(output: self)
            .build(input: .init(kind: kind))
        self.passcodeNavigationRouter.pushViewController(vc)
    }
}

// MARK: AccountPasswordModuleOutput
extension PasscodeLogInCoordinator: AccountPasswordModuleOutput {

    func accountPasswordVerifyAccess(signedWallet: DomainLayer.DTO.SignedWallet, password: String) {}

    func accountPasswordAuthorizationCompleted(wallet: DomainLayer.DTO.Wallet, password: String) {

        let vc = PasscodeModuleBuilder(output: self)
            .build(input: .init(kind: .changePasscodeByPassword(wallet,
                                                                password: password),
                                hasBackButton: true))

        self.passcodeNavigationRouter.pushViewController(vc)
    }
}
