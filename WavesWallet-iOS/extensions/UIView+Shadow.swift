//
//  UIView+Shadow.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 16/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

extension UIView {

    private enum AssociatedKeys {
        static var isAutomaticShadowPathSetting = "isAutomaticShadowPathSetting"
        static var isEnabledShadow = "isEnabledShadow"
        static var prevBounds = "prevBounds"
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

    private var isEnabledShadow: Bool {
        get {
            return associatedObject(for: &AssociatedKeys.isEnabledShadow) ?? false
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.isEnabledShadow)
        }
    }

    var isAutomaticShadowPathSetting: Bool {
        get {
            return associatedObject(for: &AssociatedKeys.isAutomaticShadowPathSetting) ?? true
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.isAutomaticShadowPathSetting)
        }
    }

    @objc private func swizzled_shadow_layoutSubviews() {
        swizzled_shadow_layoutSubviews()

        if isAutomaticShadowPathSetting == false {
            return
        }

        if isEnabledShadow == false {
            return
        }

        if prevBounds != bounds {
            if let mask = layer.mask {
                mask.shadowPath = UIBezierPath(roundedRect: mask.bounds, cornerRadius: CGFloat(cornerRadius)).cgPath
            }
            layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: CGFloat(cornerRadius)).cgPath

        }

        prevBounds = bounds
    }

    func setupShadow(options: ShadowOptions) {
        isEnabledShadow = true
        if let mask = layer.mask  {
            mask.setupShadow(options: options)
        }
        layer.setupShadow(options: options)
    }

    func removeShadow() {
        isEnabledShadow = false
        if let mask = layer.mask  {
            mask.removeShadow()
        }
        layer.removeShadow()
    }
}
