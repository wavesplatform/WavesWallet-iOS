//
//  ChooseAccountCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 28/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol ChooseAccountCoordinatorDelegate: AnyObject {
    func userChooseCompleted()
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

    private func showPasscode(wallet: DomainLayer.DTO.Wallet, animated: Bool = true) {

        //TODO: Нужно придумать другой способ
        if childCoordinators.first(where: { $0 is PasscodeCoordinator }) != nil {
            return
        }

        let passcodeCoordinator = PasscodeCoordinator(navigationController: navigationController,
                                                      kind: .logIn(wallet))
        passcodeCoordinator.animated = animated
        passcodeCoordinator.delegate = self


        addChildCoordinator(childCoordinator: passcodeCoordinator)
        passcodeCoordinator.start()
    }
}

extension ChooseAccountCoordinator: ChooseAccountModuleOutput {
    func userChoouseAccount(wallet: DomainLayer.DTO.Wallet) -> Void {
        showPasscode(wallet: wallet)
    }
}

extension ChooseAccountCoordinator: PasscodeCoordinatorDelegate {

    func userAuthorizationCompleted() {
        delegate?.userChooseCompleted()
    }

    func userLogouted() {

    }
}
