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

    enum RouterKind {
        case alertWindow
        case window(WindowRouter)
        case navigation(NavigationRouter)
    }

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    private let windowRouter: WindowRouter?
    private let passcodeNavigationRouter: NavigationRouter
    private let routerKind: RouterKind

    private let wallet: DomainLayer.DTO.Wallet

    weak var delegate: PasscodeLogInCoordinatorDelegate?

    init(wallet: DomainLayer.DTO.Wallet, routerKind: RouterKind) {

        self.routerKind = routerKind

        switch routerKind {
        case .alertWindow:

            let window = UIWindow()
            window.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
            self.windowRouter = WindowRouter(window: window)
            self.passcodeNavigationRouter = NavigationRouter(navigationController: CustomNavigationController())

        case .navigation(let navRouter):
            self.passcodeNavigationRouter = navRouter
            self.windowRouter = nil

        case .window(let window):
            self.windowRouter = window
            self.passcodeNavigationRouter = NavigationRouter(navigationController: CustomNavigationController())
        }

        self.wallet = wallet
    }

    func start() {

        switch routerKind {
        case .alertWindow, .window:

            let vc = PasscodeModuleBuilder(output: self)
                .build(input: .init(kind: .logIn(wallet),
                                    hasBackButton: false))

            guard let windowRouter = self.windowRouter else { break }
            passcodeNavigationRouter.pushViewController(vc)
            windowRouter.setRootViewController(passcodeNavigationRouter.navigationController)

        case .navigation:
            let vc = PasscodeModuleBuilder(output: self)
                .build(input: .init(kind: .logIn(wallet),
                                    hasBackButton: true))

            passcodeNavigationRouter.pushViewController(vc, animated: true) { [weak self] in
                self?.removeFromParentCoordinator()
            }
        }
    }

    private func dissmiss() {

        switch routerKind {
        case .alertWindow, .window:

            guard let windowRouter = self.windowRouter else { break }

            windowRouter.dissmissWindow(animated: nil, completed: { [weak self] in
                self?.removeFromParentCoordinator()
            })

        case .navigation:
            passcodeNavigationRouter.popViewController()
        }
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
