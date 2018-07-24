//
//  SkeletonCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 17.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import UIKit
import Skeleton

class SkeletonCell: UITableViewCell, GradientsOwner {

    @IBOutlet var views: [GradientContainerView]!

    override func awakeFromNib() {
        super.awakeFromNib()

        let baseColor = UIColor.basic100
        let nextColor = UIColor.basic50
        gradientLayers.forEach { gradientLayer in

            gradientLayer.colors = [baseColor.cgColor,
                                    nextColor.cgColor,
                                    baseColor.cgColor]
        }
    }

    var gradientLayers: [CAGradientLayer] {
        return views.map { $0.gradientLayer }
    }
}
