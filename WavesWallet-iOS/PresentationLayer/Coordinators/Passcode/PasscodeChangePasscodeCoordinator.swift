//
//  PasscodeChangePasscodeCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 25/12/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

protocol PasscodeChangePasscodeCoordinatorDelegate: AnyObject {
    func passcodeCoordinatorPasswordChanged(wallet: DomainLayer.DTO.Wallet)
}

final class PasscodeChangePasscodeCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    private let navigationRouter: NavigationRouter
    private let password: String
    private let wallet: DomainLayer.DTO.Wallet

    weak var delegate: PasscodeChangePasscodeCoordinatorDelegate?

    init(navigationRouter: NavigationRouter, wallet: DomainLayer.DTO.Wallet, password: String) {

        self.navigationRouter = navigationRouter
        self.wallet = wallet
        self.password = password
    }

    func start() {

        let vc = PasscodeModuleBuilder(output: self)
            .build(input: .init(kind: .changePasscodeByPassword(wallet, password: password),
                                hasBackButton: true))

        navigationRouter.pushViewController(vc, animated: true) { [weak self] in
            self?.removeFromParentCoordinator()
        }
    }

    private func dissmiss() {
        navigationRouter.popViewController()
        removeFromParentCoordinator()
    }
}

// MARK: PasscodeOutput
extension PasscodeChangePasscodeCoordinator: PasscodeModuleOutput {

    func passcodeVerifyAccessCompleted(_ wallet: DomainLayer.DTO.SignedWallet) {}

    func passcodeTapBackButton() {
        dissmiss()
    }

    func passcodeLogInCompleted(passcode: String, wallet: DomainLayer.DTO.Wallet, isNewWallet: Bool) {
        delegate?.passcodeCoordinatorPasswordChanged(wallet: wallet)
    }

    func passcodeUserLogouted() {}

    func passcodeLogInByPassword() {}
}
