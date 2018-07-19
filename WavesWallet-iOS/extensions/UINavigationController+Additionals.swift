//
//  UINavigationController+Additionals.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/19/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    func pushViewControllerAndSetLast(_ viewController: UIViewController) {
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.viewControllers = [self.viewControllers.last!]
        }
        pushViewController(viewController, animated: true)
        CATransaction.commit()
    }
}

