//
//  ChooseAccountCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 28/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class ChooseAccountCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

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

//        let passcodeCoordinator = PasscodeCoordinator(viewController: window.rootViewController!,
//                                                      kind: .logIn(wallet))
//        passcodeCoordinator.animated = animated
//        passcodeCoordinator.delegate = self
//
//
//        addChildCoordinator(childCoordinator: passcodeCoordinator)
//        passcodeCoordinator.start()
    }
}

extension ChooseAccountCoordinator: ChooseAccountModuleOutput {

}
