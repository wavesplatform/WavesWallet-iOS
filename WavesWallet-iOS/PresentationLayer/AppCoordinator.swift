//
//  AppCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 13.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

final class AppCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    private let window: UIWindow

    init(_ window: UIWindow) {
        self.window = window
    }

    func start() {
        let info = WalletManager.isWalletLoggedIn
        if let item = info.item, info.isLoggedIn == true {
            WalletManager.didLogin(toWallet: item)
        } else {
            let helloCoordinator = HelloCoordinator(window)
            addChildCoordinator(childCoordinator: helloCoordinator)
            helloCoordinator.start()
        }
    }

    func showStartController() {
//                    self.window!.rootViewController = StoryboardManager.launchViewController()
    }
}




