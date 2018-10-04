//
//  UIView+Shadow.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 16/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

fileprivate enum Constants {
    static let deffaultCornerRadius: Float = -1
}

extension UIView {

    private enum AssociatedKeys {
        static var cornerRadius = "cornerRadius"
        static var maskLayer = "maskLayer"
        static var prevBounds = "prevBounds"
        static var shadowOptions = "shadowOptions"
        static var isInvalidatePath = "isInvalidatePath"
    }

    static func shadowInit() {
        Runtime.swizzle(for: self,
                        original: #selector(layoutSubviews),
                        swizzled: #selector(swizzled_shadow_layoutSubviews))
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

    private var shadowOptions: ShadowOptions? {
        get {
            return associatedObject(for: &AssociatedKeys.shadowOptions) ?? nil
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.shadowOptions)
        }
    }

    private var isInvalidatePath: Bool {

        get {
            return associatedObject(for: &AssociatedKeys.isInvalidatePath) ?? false
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.isInvalidatePath)
        }
    }


    @IBInspectable var cornerRadius: Float {

        get {
            return associatedObject(for: &AssociatedKeys.cornerRadius) ?? Constants.deffaultCornerRadius
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.cornerRadius)
            update()
        }
    }

    func setupShadow(options: ShadowOptions) {
        self.shadowOptions = options
        update()
    }

    func removeShadow() {
        self.shadowOptions = nil
        update()
    }
}

extension UIView {

    private var isNeedUpdateLayout: Bool {
        get {
            return (cornerRadius != Constants.deffaultCornerRadius) || shadowOptions != nil
        }
    }

    private func update() {
        if cornerRadius != Constants.deffaultCornerRadius {
            layer.clip(cornerRadius: CGFloat(cornerRadius))
        } else {
            layer.removeClip()
        }

        if let shadowOptions = shadowOptions {
            if let mask = layer.mask  {
                mask.setupShadow(options: shadowOptions)
                layer.mask = mask
            }
//            layer.setupShadow(options: shadowOptions)
        } else {
            if let mask = layer.mask  {
                mask.removeShadow()
            }
            layer.removeShadow()
        }
        isInvalidatePath = true
    }

    @objc private func swizzled_shadow_layoutSubviews() {
        swizzled_shadow_layoutSubviews()

        if isNeedUpdateLayout == false {
            return
        }

//        if prevBounds != bounds || isInvalidatePath {
//            isInvalidatePath = false

            let path = UIBezierPath(roundedRect: bounds, cornerRadius: CGFloat(cornerRadius)).cgPath
            if let mask = layer.mask {
                mask.shadowPath = path
            }
            if let mask = layer.mask as? CAShapeLayer {
                mask.frame = bounds
                mask.path = path
            }
            layer.shadowPath = path
//        }

//        prevBounds = bounds
    }
}
