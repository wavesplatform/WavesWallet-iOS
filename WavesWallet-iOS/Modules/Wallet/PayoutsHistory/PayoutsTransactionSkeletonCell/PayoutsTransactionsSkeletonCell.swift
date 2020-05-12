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
import UITools

class PayoutsTransactionsSkeletonCell: UITableViewCell, NibReusable, SkeletonAnimatable {
    @IBOutlet private weak var shadowContainerView: UIView!
    @IBOutlet private var views: [GradientContainerView]!

    var gradientLayers: [CAGradientLayer] { views.map { $0.gradientLayer } }

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .basic50
        contentView.backgroundColor = .basic50

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

        shadowContainerView.setupDefaultShadows()
    }
}
