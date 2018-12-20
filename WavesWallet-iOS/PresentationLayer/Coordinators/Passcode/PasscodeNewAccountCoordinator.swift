//
//  PasscodeNewAccountCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 20/12/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

protocol PasscodeNewAccountCoordinatorDelegate: AnyObject {
    func passcodeCoordinatorCreatedWallet(wallet: DomainLayer.DTO.Wallet)
}

final class PasscodeNewAccountCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    private let navigationRouter: NavigationRouter

    private let account: PasscodeTypes.DTO.Account

    weak var delegate: PasscodeNewAccountCoordinatorDelegate?

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
    }

    private func dissmiss() {
        navigationRouter.popViewController()
        removeFromParentCoordinator()
    }
}

// MARK: PresentationCoordinator

extension PasscodeNewAccountCoordinator: PresentationCoordinator {

    enum Display {
        case useTouchID(wallet: DomainLayer.DTO.Wallet, passcode: String)
    }

    func showDisplay(_ display: Display) {
        switch display {

        case .useTouchID(let wallet, let passcode):
            let vc = UseTouchIDModuleBuilder(output: self).build(input: .init(passcode: passcode, wallet: wallet))
            navigationRouter.present(vc)

        }
    }

}

// MARK: PasscodeOutput
extension PasscodeNewAccountCoordinator: PasscodeModuleOutput {

    func passcodeVerifyAccessCompleted(_ wallet: DomainLayer.DTO.SignedWallet) {}

    func passcodeTapBackButton() {
        dissmiss()
    }

    func passcodeLogInCompleted(passcode: String, wallet: DomainLayer.DTO.Wallet, isNewWallet: Bool) {

        if isNewWallet, BiometricType.enabledBiometric != .none {
            showDisplay(.useTouchID(wallet: wallet, passcode: passcode))
        } else {
            delegate?.passcodeCoordinatorCreatedWallet(wallet: wallet)
            dissmiss()
        }
    }

    func passcodeUserLogouted() {}

    func passcodeLogInByPassword() {}
}

// MARK: UseTouchIDModuleOutput
extension PasscodeNewAccountCoordinator: UseTouchIDModuleOutput {

    func userSkipRegisterBiometric(wallet: DomainLayer.DTO.Wallet) {

        navigationRouter.dismiss(animated: true, completion: nil)
        delegate?.passcodeCoordinatorCreatedWallet(wallet: wallet)
        dissmiss()
    }

    func userRegisteredBiometric(wallet: DomainLayer.DTO.Wallet) {

        navigationRouter.dismiss(animated: true, completion: nil)
        delegate?.passcodeCoordinatorCreatedWallet(wallet: wallet)
        dissmiss()
    }
}
