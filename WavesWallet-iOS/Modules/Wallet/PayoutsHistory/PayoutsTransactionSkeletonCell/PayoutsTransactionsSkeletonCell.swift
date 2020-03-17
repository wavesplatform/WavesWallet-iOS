//
//  PayoutsTransactionsSkeletonCell.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 16.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Extensions
import Skeleton
import UIKit

class PayoutsTransactionsSkeletonCell: UITableViewCell, NibReusable, SkeletonAnimatable {
    
    @IBOutlet private weak var shadowContainerView: UIView!
    
    @IBOutlet private var views: [GradientContainerView]!
    
    var gradientLayers: [CAGradientLayer] { views.map { $0.gradientLayer } }

    override func awakeFromNib() {
        super.awakeFromNib()
        
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
        
        do {
            let shadowColor = UIColor.black.withAlphaComponent(0.08)
            let shadowOptions = ShadowOptions(offset: CGSize(width: 0, height: 0),
                                              color: shadowColor,
                                              opacity: 1,
                                              shadowRadius: 4,
                                              shouldRasterize: true)
            shadowContainerView.setupShadow(options: shadowOptions)
        }
    }
}
