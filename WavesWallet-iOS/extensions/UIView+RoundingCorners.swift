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
        static var prevBounds = "prevBounds"
    }

    static func roundedInit() {
        Runtime.swizzle(for: self,
                        original: #selector(layoutSubviews),
                        swizzled: #selector(swizzledLayoutSubviews))
    }

    private var prevBounds: CGRect? {

        get {
            if let value: NSValue = associatedObject(for: &AssociatedKeys.prevBounds) {
                return value.cgRectValue
            }
            return nil
        }

        set {

            if let newValue = newValue {
                setAssociatedObject(NSValue(cgRect: newValue), for: &AssociatedKeys.prevBounds)
            } else {
                let value: NSValue? = nil
                setAssociatedObject(value, for: &AssociatedKeys.prevBounds)
            }
        }
    }

    @IBInspectable var cornerRadius: Float {

        get {
            return associatedObject(for: &AssociatedKeys.cornerRadius) ?? Constants.deffaultCornerRadius
        }

        set {

            let oldValue = cornerRadius
            setAssociatedObject(newValue, for: &AssociatedKeys.cornerRadius)

            if oldValue != newValue {
                setNeedsLayout()
            }
        }
    }

    @objc private func swizzledLayoutSubviews() {
        swizzledLayoutSubviews()

        if cornerRadius == Constants.deffaultCornerRadius {
            return
        }

        if prevBounds != bounds {
            layer.clip(cornerRadius: CGFloat(cornerRadius))
        }
        prevBounds = bounds
    }
}
