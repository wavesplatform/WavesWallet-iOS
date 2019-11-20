//
//  UIView+Animation.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 18.09.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit

public extension UIView {

    public static let fastDurationAnimation: TimeInterval = 0.24

    func shake() {
        self.transform = CGAffineTransform(translationX: 20, y: 0)
        UIView.animate(withDuration: UIView.fastDurationAnimation, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
}
