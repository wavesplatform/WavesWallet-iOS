//
//  UIButton+WithoutAnimation.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 26/09/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit

public extension UIButton {
    func setTitleWithoutAnimated(_ title: String?, for state: UIControl.State) {
        UIView.performWithoutAnimation {
            setTitle(title, for: state)
        }
    }
}

