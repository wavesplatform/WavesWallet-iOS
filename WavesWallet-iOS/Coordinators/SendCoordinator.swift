//
//  SendCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 30.10.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Extensions
import Foundation

final class SendCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    weak var parent: Coordinator?

    private var navigationRouter: NavigationRouter
    private var windowRouter: WindowRouter
    private var deepLink: DeepLink

    init(windowRouter _: WindowRouter, deepLink: DeepLink) {
        self.deepLink = deepLink
        let window = UIWindow()
        window.windowLevel = UIWindow.Level(rawValue: UIWindow.Level.normal.rawValue + 1.0)
        windowRouter = WindowRouter.windowFactory(window: window)
        navigationRouter = NavigationRouter(navigationController: CustomNavigationController())

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(dismiss),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
    }

    func start() {
        if let vc = SendModuleBuilder().build(input: .deepLink(deepLink)) as? SendViewController {
            windowRouter.setRootViewController(navigationRouter.navigationController)
            navigationRouter.pushViewController(vc)
            vc.backTappedAction = { [weak self] in
                guard let self = self else { return }
                self.dismiss()
            }
        }
    }

    @objc private func dismiss() {
        windowRouter.dissmissWindow(animated: nil, completed: { [weak self] in
            guard let self = self else { return }
            self.removeFromParentCoordinator()
        })
    }
}
