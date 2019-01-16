//
//  ChooseAccountCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 28/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol ChooseAccountCoordinatorDelegate: AnyObject {
    func userChooseCompleted(wallet: DomainLayer.DTO.Wallet)
}

final class ChooseAccountCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    weak var delegate: ChooseAccountCoordinatorDelegate?
    private let navigationRouter: NavigationRouter
    private weak var applicationCoordinator: ApplicationCoordinatorProtocol?

    init(navigationRouter: NavigationRouter, applicationCoordinator: ApplicationCoordinatorProtocol) {
        self.navigationRouter = navigationRouter
        self.applicationCoordinator = applicationCoordinator
    }

    func start() {
        let vc = ChooseAccountModuleBuilder(output: self)
            .build(input: .init())
        navigationRouter.pushViewController(vc, animated: true, completion: { [weak self] in
            self?.removeFromParentCoordinator()
        })
    }

    private func showEdit(wallet: DomainLayer.DTO.Wallet, animated: Bool = true) {
        let editCoordinator = EditAccountNameCoordinator(navigationRouter: navigationRouter, wallet: wallet)
        addChildCoordinatorAndStart(childCoordinator: editCoordinator)
    }

    private func showAccountPassword(kind: AccountPasswordTypes.DTO.Kind) {

        let vc = AccountPasswordModuleBuilder(output: self)
            .build(input: .init(kind: kind))
        navigationRouter.pushViewController(vc)
    }
}

// MARK: PresentationCoordinator

extension ChooseAccountCoordinator: PresentationCoordinator {

    enum Display {
        case passcodeLogIn(DomainLayer.DTO.Wallet)
        case passcodeChangePasscode(DomainLayer.DTO.Wallet, password: String)
        case editAccountName(DomainLayer.DTO.Wallet)
        case accountPasswordLogIn(DomainLayer.DTO.Wallet)
    }

    func showDisplay(_ display: Display) {
        switch display {

        case .passcodeLogIn(let wallet):
            guard isHasCoordinator(type: PasscodeLogInCoordinator.self) != true else { return }

            let passcodeCoordinator = PasscodeLogInCoordinator(wallet: wallet, routerKind: .navigation(navigationRouter))
            passcodeCoordinator.delegate = self

            addChildCoordinatorAndStart(childCoordinator: passcodeCoordinator)

        case .passcodeChangePasscode(let wallet, let password):
            guard isHasCoordinator(type: PasscodeChangePasscodeCoordinator.self) != true else { return }

            let passcodeCoordinator = PasscodeChangePasscodeCoordinator(navigationRouter: navigationRouter,
                                                                        wallet: wallet,
                                                                        password: password)
            passcodeCoordinator.delegate = self

            addChildCoordinatorAndStart(childCoordinator: passcodeCoordinator)

        case .editAccountName(let wallet):
            showEdit(wallet: wallet)

        case .accountPasswordLogIn(let wallet):
            showAccountPassword(kind: .logIn(wallet))
        }
    }

}

// MARK: ChooseAccountModuleOutput
extension ChooseAccountCoordinator: ChooseAccountModuleOutput {
    
    func userChooseAccount(wallet: DomainLayer.DTO.Wallet, passcodeNotCreated: Bool) -> Void {
        if passcodeNotCreated {
            showDisplay(.accountPasswordLogIn(wallet))
        } else {
            showDisplay(.passcodeLogIn(wallet))
        }
    }
    
    func userEditAccount(wallet: DomainLayer.DTO.Wallet) {
        showDisplay(.editAccountName(wallet))
    }
}

// MARK: AccountPasswordModuleOutput
extension ChooseAccountCoordinator: AccountPasswordModuleOutput {

    func accountPasswordAuthorizationCompleted(wallet: DomainLayer.DTO.Wallet, password: String) {
        showDisplay(.passcodeChangePasscode(wallet, password: password))
    }

    func accountPasswordVerifyAccess(signedWallet: DomainLayer.DTO.SignedWallet, password: String) {}
}

// MARK: PasscodeLogInCoordinatorDelegate
extension ChooseAccountCoordinator: PasscodeLogInCoordinatorDelegate {

    func passcodeCoordinatorLogInCompleted(wallet: DomainLayer.DTO.Wallet) {
        delegate?.userChooseCompleted(wallet: wallet)
        removeFromParentCoordinator()
    }
}

// MARK: PasscodeCoordinatorDelegate
extension ChooseAccountCoordinator: PasscodeCoordinatorDelegate {

    func passcodeCoordinatorVerifyAcccesCompleted(signedWallet: DomainLayer.DTO.SignedWallet) {}

    func passcodeCoordinatorAuthorizationCompleted(wallet: DomainLayer.DTO.Wallet) {
        delegate?.userChooseCompleted(wallet: wallet)
        removeFromParentCoordinator()
    }

    func passcodeCoordinatorWalletLogouted() {
        self.applicationCoordinator?.showEnterDisplay()
        removeFromParentCoordinator()
    }
}

// MARK: PasscodeChangePasscodeCoordinator
extension ChooseAccountCoordinator: PasscodeChangePasscodeCoordinatorDelegate {

    func passcodeCoordinatorPasswordChanged(wallet: DomainLayer.DTO.Wallet) {
        delegate?.userChooseCompleted(wallet: wallet)
        removeFromParentCoordinator()
    }
}


