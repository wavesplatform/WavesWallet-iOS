//
//  ChooseAccountCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 28/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

final class ChooseAccountCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    private let navigationController: UINavigationController

    init(navigationController: UIViewController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = ChooseAccountModuleBuilder(output: self).build(input: .init(kind: kind))
        navigationController.pushViewController(vc, animated: true)

        if let presentedViewController = viewController.presentedViewController {
            presentedViewController.present(navigationController, animated: true, completion: nil)
        } else {
            viewController.present(navigationController, animated: animated, completion: nil)
        }
}
