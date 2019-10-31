//
//  DexDeepLinkCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 31.10.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import Extensions

final class DexDeepLinkCoordinator: DexCoordinator {
    
    private var navigationRouter: NavigationRouter
    private var windowRouter: WindowRouter
    private var deepLink: DeepLink
    
    init(windowRouter: WindowRouter, deepLink: DeepLink) {
        
        self.deepLink = deepLink
        let window = UIWindow()
        window.windowLevel = UIWindow.Level(rawValue: UIWindow.Level.normal.rawValue + 1.0)
        self.windowRouter = WindowRouter.windowFactory(window: window)
        self.navigationRouter = NavigationRouter(navigationController: CustomNavigationController())
        super.init(navigationRouter: navigationRouter)

        NotificationCenter.default.addObserver(self, selector: #selector(dismiss), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    override func start() {
        
        let pair = DexTraderContainer.DTO.Pair(amountAsset: .init(id: "", name: "", shortName: "", decimals: 0), priceAsset: .init(id: "", name: "", shortName: "", decimals: 0), isGeneral: false)
        let vc = DexTraderContainerModuleBuilder(output: self, orderBookOutput: self, lastTradesOutput: self, myOrdersOutpout: self).build(input: pair)
        windowRouter.setRootViewController(self.navigationRouter.navigationController)
        navigationRouter.pushViewController(vc)
    }
    
    @objc private func dismiss() {
       windowRouter.dissmissWindow(animated: nil, completed: { [weak self] in
           guard let self = self else { return }
           self.removeFromParentCoordinator()
       })
    }
}
