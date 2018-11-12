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
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = ChooseAccountModuleBuilder(output: self).build(input: .init())
        navigationController.pushViewController(vc, animated: true)
    }

    private func showPasscode(kind: PasscodeTypes.DTO.Kind, animated: Bool = true) {

        //TODO: Нужно придумать другой способ
        if childCoordinators.first(where: { $0 is PasscodeCoordinator }) != nil {
            return
        }

        let passcodeCoordinator = PasscodeCoordinator(navigationController: navigationController,
                                                      kind: kind)
        passcodeCoordinator.animated = animated
        passcodeCoordinator.delegate = self

        addChildCoordinator(childCoordinator: passcodeCoordinator)
        passcodeCoordinator.start()
    }
    
    private func showEdit(wallet: DomainLayer.DTO.Wallet, animated: Bool = true) {
        // TODO: как сделаю edit, заменю на координатор
        let vc = StoryboardScene.Enter.editAccountNameViewController.instantiate()
        navigationController.pushViewController(vc, animated: true)
    }

    func showAccountPassword(kind: AccountPasswordTypes.DTO.Kind) {

        let vc = AccountPasswordModuleBuilder(output: self)
            .build(input: .init(kind: kind))
        navigationController.pushViewController(vc, animated: true)
    }
}

extension ChooseAccountCoordinator: ChooseAccountModuleOutput {
    
    func userChooseAccount(wallet: DomainLayer.DTO.Wallet, passcodeNotCreated: Bool) -> Void {
        if passcodeNotCreated {
            showAccountPassword(kind: .logIn(wallet))
        } else {
            showPasscode(kind: .logIn(wallet))
        }
    }
    
    func userEditAccount(wallet: DomainLayer.DTO.Wallet) {
        showEdit(wallet: wallet)
    }
}


// MARK: AccountPasswordModuleOutput
extension ChooseAccountCoordinator: AccountPasswordModuleOutput {

    func accountPasswordAuthorizationCompleted(wallet: DomainLayer.DTO.Wallet, password: String) {
        showPasscode(kind: .changePasscodeByPassword(wallet, password: password))
    }

    func accountPasswordVerifyAccess(signedWallet: DomainLayer.DTO.SignedWallet, password: String) {}
}

// MARK: PasscodeCoordinatorDelegate
extension ChooseAccountCoordinator: PasscodeCoordinatorDelegate {

    func passcodeCoordinatorVerifyAcccesCompleted(signedWallet: DomainLayer.DTO.SignedWallet) {}

    func passcodeCoordinatorAuthorizationCompleted(wallet: DomainLayer.DTO.Wallet) {
        delegate?.userChooseCompleted(wallet: wallet)
    }

    func passcodeCoordinatorWalletLogouted() {

    }
}
