//
//  WalletCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 24.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class WalletCoordinator {
    private lazy var walletViewContoller: UIViewController = {
        return WalletModuleBuilder(output: self).build()
    }()

    private var navigationController: UINavigationController!

    func start(navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigationController.pushViewController(walletViewContoller, animated: false)
    }
}

extension WalletCoordinator: WalletModuleOutput {
    func showWalletSort() {
        let vc = WalletSortModuleBuilder().build()
        navigationController.pushViewController(vc, animated: true)
    }

    func showMyAddress() {
        let vc = StoryboardScene.Main.myAddressViewController.instantiate()
        navigationController.pushViewController(vc, animated: true)
    }
}
