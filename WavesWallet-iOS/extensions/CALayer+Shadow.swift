//
//  CALayer+Shadow.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 16/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct ShadowOptions {
    let offset: CGSize
    let color: UIColor
    let opacity: Float
    let shadowRadius: Float
    let shouldRasterize: Bool
}

extension CALayer {

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
        shadowPath = nil
    }
}
