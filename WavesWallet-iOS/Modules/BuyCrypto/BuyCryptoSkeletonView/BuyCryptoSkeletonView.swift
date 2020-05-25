//
//  BuyCryptoSkeletonView.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 25.05.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Skeleton
import UITools
import UIKit

final class BuyCryptoSkeletonView: UIView, NibLoadable, SkeletonAnimatable {
    @IBOutlet private var views: [GradientContainerView]!
    
    var gradientLayers: [CAGradientLayer] { views.map { $0.gradientLayer } }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        
        views.forEach {
            $0.layer.masksToBounds = true
            $0.backgroundColor = .clear
        }

        let baseColor = UIColor.basic100
        let nextColor = UIColor.basic50
        gradientLayers.forEach { gradientLayer in

            gradientLayer.colors = [baseColor.cgColor,
                                    nextColor.cgColor,
                                    baseColor.cgColor]
        }
    }
}
