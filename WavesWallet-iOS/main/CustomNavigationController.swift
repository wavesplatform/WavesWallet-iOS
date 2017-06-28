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
        return .lightContent
    }
    
    
    static func customizeNavBar(_ navigationBar: UINavigationBar?) {
        if let navigationBar = navigationBar {
            navigationBar.barTintColor = AppColors.wavesColor
            navigationBar.tintColor = AppColors.activeColor
            navigationBar.isTranslucent = false
            
            navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: AppColors.activeColor]
            
            navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationBar.shadowImage = UIImage()
        }
    }

}
