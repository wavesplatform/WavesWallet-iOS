//
//  UIView+Passtrough.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 10/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

extension UIView {

    private enum AssociatedKeys {
        static var shouldPassthroughTouch = "shouldPassthroughTouch"
        static var passthroughFrame = "passthroughFrame"
        static var isEnabledPassthroughSubviews = "isEnabledPassthroughSubviews"
    }

    static func passtroughInit() {
        Runtime.swizzle(for: self,
                        original: #selector(hitTest(_:with:)),
                        swizzled: #selector(swizzledHitTest(_:with:)))
    }
    
    var isEnabledPassthroughSubviews: Bool {

        get {
            return associatedObject(for: &AssociatedKeys.isEnabledPassthroughSubviews) ?? false
        }

        set {

            let oldValue = isEnabledPassthroughSubviews
            setAssociatedObject(newValue, for: &AssociatedKeys.isEnabledPassthroughSubviews)

            if oldValue != newValue {
                setupSubviews(isEnabledSubviews: newValue)
            }
        }
    }

    var passthroughFrame: CGRect? {

        get {
            if let value: NSValue = associatedObject(for: &AssociatedKeys.passthroughFrame) {
                return value.cgRectValue
            }
            return nil
        }

        set {

            let oldValue = passthroughFrame

            if let newValue = newValue {
                setAssociatedObject(NSValue(cgRect: newValue), for: &AssociatedKeys.passthroughFrame)
            } else {
                let value: NSValue? = nil
                setAssociatedObject(value, for: &AssociatedKeys.passthroughFrame)
            }

            if oldValue != newValue {
                setupSubviews(isEnabledSubviews: isEnabledPassthroughSubviews)
            }
        }
    }

    @IBInspectable var shouldPassthroughTouch: Bool {

        get {
            return associatedObject(for: &AssociatedKeys.shouldPassthroughTouch) ?? false
        }

        set {

            let oldValue = shouldPassthroughTouch
            setAssociatedObject(newValue, for: &AssociatedKeys.shouldPassthroughTouch)

            if oldValue != newValue {
                setupSubviews(isEnabledSubviews: isEnabledPassthroughSubviews)
            }
        }
    }

    private func setupSubviews(isEnabledSubviews: Bool) {

        for view in subviews {
            if isEnabledSubviews {
                view.shouldPassthroughTouch = shouldPassthroughTouch
                view.passthroughFrame = passthroughFrame
            } else {
                view.shouldPassthroughTouch = false
                view.passthroughFrame = nil
            }
        }
    }

    @objc func swizzledHitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = swizzledHitTest(point, with: event)

        if shouldPassthroughTouch && view == self {
            if let passthroughFrame = passthroughFrame {
                if passthroughFrame.contains(point) == false {
                    return view
                } else {
                    return nil
                }
            } else {
                return nil
            }
        } else {
            return view
        }
    }
}
