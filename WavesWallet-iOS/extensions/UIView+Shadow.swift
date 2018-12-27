//
//  UIView+Shadow.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 16/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

fileprivate enum Constants {
    static let deffaultValue: Float = -1
}

extension UIView {

    private enum AssociatedKeys {
        static var cornerRadius = "cornerRadius"
        static var maskLayer = "maskLayer"
        static var prevBounds = "prevBounds"
        static var shadowOptions = "shadowOptions"
        static var borderWidth = "borderWidth"
        static var borderColor = "borderColor"
        static var isInvalidatePath = "isInvalidatePath"
    }

    static func shadowInit() {
        Runtime.swizzle(for: self,
                        original: #selector(layoutSubviews),
                        swizzled: #selector(swizzled_shadow_layoutSubviews))
    }

    private var shadowOptions: ShadowOptions? {
        get {
            return associatedObject(for: &AssociatedKeys.shadowOptions) ?? nil
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.shadowOptions)
        }
    }

    @IBInspectable var cornerRadius: Float {

        get {
            return associatedObject(for: &AssociatedKeys.cornerRadius) ?? Constants.deffaultValue
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.cornerRadius)
            update()
            
        }
    }

    @IBInspectable var borderWidth: Float {

        get {
            return associatedObject(for: &AssociatedKeys.borderWidth) ?? Constants.deffaultValue
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.borderWidth)
            update()

        }
    }

    @IBInspectable var borderColor: UIColor? {

        get {
            return associatedObject(for: &AssociatedKeys.borderColor)
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.borderColor)
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

    private func update() {
        if let shadowOptions = shadowOptions {
            layer.setupShadow(options: shadowOptions)
        } else {
            layer.removeShadow()
        }

        if self.cornerRadius != Constants.deffaultValue {
            layer.cornerRadius = CGFloat(self.cornerRadius)
            layer.shouldRasterize = true
            layer.rasterizationScale = UIScreen.main.scale
            
            //corner ratius in UIImageView not working wihout masksToBounds
            if layer.masksToBounds == false && self is UIImageView {
                layer.masksToBounds = true
                warning("Corner radius dont work, need enable mask to bounds")
            }
        }

        if self.borderWidth != Constants.deffaultValue {
            layer.borderWidth = CGFloat(self.borderWidth) / UIScreen.main.scale
            layer.borderColor = self.borderColor?.cgColor
        }

        
    }

    @objc private func swizzled_shadow_layoutSubviews() {
        swizzled_shadow_layoutSubviews()

        if self.shadowOptions != nil {
            let path = UIBezierPath(roundedRect: bounds, cornerRadius: CGFloat(cornerRadius)).cgPath
            layer.shadowPath = path
        } else {
            layer.shadowPath = nil
        }
    }
}
