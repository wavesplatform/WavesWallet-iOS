//
//  UIView+Layer.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 17/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit

public extension UIView {
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return layer.borderColor.map { UIColor(cgColor: $0) }
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }

    
}
