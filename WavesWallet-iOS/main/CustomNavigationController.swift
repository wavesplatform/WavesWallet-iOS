//
//  CustomNavigationController.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 17/03/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        CustomNavigationController.customizeNavBar(navigationBar)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    
    static func customizeNavBar(_ navigationBar: UINavigationBar?) {
        if let navigationBar = navigationBar {
            navigationBar.barTintColor = AppColors.mainBgColor
            navigationBar.tintColor = AppColors.activeColor
            navigationBar.isTranslucent = true
            
            navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: AppColors.activeColor]
            
            //navigationBar.setBackgroundImage(UIImage(), for: .default)
            //navigationBar.shadowImage = UIImage()
        }
    }

}
