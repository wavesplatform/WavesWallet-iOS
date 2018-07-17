//
//  AssetSkeletonCell.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 17/07/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
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

final class WalletAssetSkeletonCell: SkeletonCell, Reusable {
    @IBOutlet var viewContent: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        viewContent.addTableCellShadowStyle()
        backgroundColor = UIColor.basic50
    }

    class func cellHeight() -> CGFloat {
        return 76
    }
}
