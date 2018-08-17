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
    }

    static func passtroughInit() {
        Runtime.swizzle(for: self,
                        original: #selector(layoutSubviews),
                        swizzled: #selector(swizzled_shadow_layoutSubviews))
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

        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: CGFloat(cornerRadius)).cgPath
        if let mask = layer.mask {
            mask.shadowPath = UIBezierPath(roundedRect: mask.bounds, cornerRadius: CGFloat(cornerRadius)).cgPath
        }
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
