//
//  RoundedView.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 16.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let deffaultCornerRadius: Float = -1
}

extension UIView {

    private enum AssociatedKeys {
        static var cornerRadius = "cornerRadius"
        static var passthroughFrame = "passthroughFrame"
        static var isEnabledPassthroughSubviews = "isEnabledPassthroughSubviews"
    }

    static func roundedInit() {
        Runtime.swizzle(for: self,
                        original: #selector(layoutSubviews),
                        swizzled: #selector(swizzledLayoutSubviews))
    }

    @IBInspectable var cornerRadius: Float {

        get {
            return associatedObject(for: &AssociatedKeys.cornerRadius) ?? Constants.deffaultCornerRadius
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.cornerRadius)
            setNeedsLayout()
        }
    }

    @objc func swizzledLayoutSubviews() {
        swizzledLayoutSubviews()

        if cornerRadius == Constants.deffaultCornerRadius {
            layer.removeClip()
        } else {
            layer.clip(cornerRadius: CGFloat(cornerRadius))
        }
    }
}
