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
        static var maskLayer = "maskLayer"
    }

    static func roundedInit() {
        Runtime.swizzle(for: self,
                        original: #selector(layoutSubviews),
                        swizzled: #selector(swizzled_RoundingCorners_LayoutSubviews))
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
            setAssociatedObject(newValue, for: &AssociatedKeys.cornerRadius)
            layer.clip(cornerRadius: CGFloat(cornerRadius))
        }
    }

    @objc private func swizzled_RoundingCorners_LayoutSubviews() {
        swizzled_RoundingCorners_LayoutSubviews()

        if cornerRadius == Constants.deffaultCornerRadius {
            return
        }

        guard let mask = layer.mask as? CAShapeLayer else { return }
        
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: .allCorners,
                                cornerRadii: CGSize(width: CGFloat(cornerRadius),
                                                    height: CGFloat(cornerRadius)))

        mask.frame = bounds
        mask.path = path.cgPath
    }
}
