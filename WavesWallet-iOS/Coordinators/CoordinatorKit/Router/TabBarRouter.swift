//
//  TabBarRouter.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 17/01/2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import UIKit

final class TabBarRouter: NSObject {

    public var tabBarController: UITabBarController

    public init(tabBarController: UITabBarController) {
        self.tabBarController = tabBarController
        super.init()
    }

    func setViewControllers(_ viewControllers: [UIViewController]) {
        tabBarController.viewControllers = viewControllers
    }
    
    func setSelectedIndex(_ selectedIndex: Int) {
        tabBarController.selectedIndex = selectedIndex
    }
}

extension TabBarRouter: Router {
    var viewController: UIViewController {
        return tabBarController
    }
}
