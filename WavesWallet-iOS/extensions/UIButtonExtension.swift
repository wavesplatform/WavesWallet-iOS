//
//  UIButtonExtension.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 11/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit

extension UIButton {
    override open var isEnabled: Bool {
        didSet {
            updateAlphaForEnabledState()
        }
    }

    func updateAlphaForEnabledState() {
        if isEnabled {
            self.alpha = 1
        } else {
            self.alpha = 0.5
        }
    }
}
