//
//  AssetSkeletonCell.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 17/07/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import Skeleton

class AssetSkeletonCell: UITableViewCell, Reusable {
    @IBOutlet var iconView: GradientContainerView!
    @IBOutlet var viewTitle: GradientContainerView!

    override func awakeFromNib() {
        super.awakeFromNib()

        gradientLayers.forEach { gradientLayer in
            let baseColor = UIColor.red
            gradientLayer.colors = [baseColor.cgColor,
                                    UIColor.blue.cgColor,
                                    baseColor.cgColor]
        }
        slide(to: .left)
    }

    class func cellHeight() -> CGFloat {
        // cell height 68 and 8 bottom pading
        return 76
    }
}

extension AssetSkeletonCell: GradientsOwner {
    var gradientLayers: [CAGradientLayer] {
        return [iconView.gradientLayer, viewTitle.gradientLayer]
    }
}
