//
//  CALayer+Shadow.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 16/08/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit

public struct ShadowOptions {
    public let offset: CGSize
    public let color: UIColor
    public let opacity: Float
    public let shadowRadius: Float
    public let shouldRasterize: Bool

    public init(offset: CGSize, color: UIColor, opacity: Float, shadowRadius: Float, shouldRasterize: Bool) {
        self.offset = offset
        self.color = color
        self.opacity = opacity
        self.shadowRadius = shadowRadius
        self.shouldRasterize = shouldRasterize
    }
}

public extension CALayer {

    func setupShadow(options: ShadowOptions) {
        shadowColor = options.color.cgColor
        shadowOffset = options.offset
        shadowOpacity = options.opacity
        shadowRadius = CGFloat(options.shadowRadius)
        shouldRasterize = options.shouldRasterize
        if shouldRasterize {
            rasterizationScale = UIScreen.main.scale
        }        
    }

    func removeShadow() {
        shadowColor = nil
        shadowOffset = CGSize.zero
        shadowOpacity = 0
        shadowRadius = 0
        shouldRasterize = false
        rasterizationScale = 1
        cornerRadius = 0
    }
}
