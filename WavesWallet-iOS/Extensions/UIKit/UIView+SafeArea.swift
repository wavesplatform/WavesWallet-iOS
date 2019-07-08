//
//  UIView+SafeArea.swift
//  WavesWallet-iOS
//
//  Created by Mac on 28/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit


extension UIView {
    
    var layoutInsets: UIEdgeInsets {
    
        if #available(iOS 11.0, *) {
            return UIEdgeInsets(top: safeAreaInsets.top,
                                left: safeAreaInsets.left,
                                bottom: safeAreaInsets.bottom,
                                right: safeAreaInsets.right)
        } else {
            return .zero
        }
    }
}
