//
//  WrapperAssetsSegmentedControl.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 10/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let maxCount = 3
}

final class WrapperAssetsSegmentedControl: UIView, ViewConfiguration {
    @IBOutlet private(set) var assetsSegmentedControl: AssetsSegmentedControl!
    private var leftGradient: GradientView = GradientView()
    private var rightGradient: GradientView = GradientView()

    override func awakeFromNib() {
        super.awakeFromNib()
        leftGradient.startColor = .basic50
        leftGradient.direction = .horizontal
        leftGradient.endColor = .clear
        rightGradient.direction = .horizontal
        rightGradient.startColor = .clear
        rightGradient.endColor = .basic50
        backgroundColor = .basic50
        assetsSegmentedControl.backgroundColor = .basic50
        addSubview(leftGradient)
        addSubview(rightGradient)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let witdthCells = assetsSegmentedControl.witdthCells(by: Constants.maxCount)

        leftGradient.frame = CGRect(x: 0,
                                    y: 0,
                                    width: (frame.width - witdthCells) * 0.5,
                                    height: AssetsSegmentedCell.Constants.sizeLogo.height)
        rightGradient.frame = CGRect(x: frame.width - (frame.width - witdthCells) * 0.5,
                                     y: 0,
                                     width: (frame.width - witdthCells) * 0.5,
                                     height: AssetsSegmentedCell.Constants.sizeLogo.height)
    }

    func update(with model: AssetsSegmentedControl.Model) {
        assetsSegmentedControl.update(with: model)
        setNeedsLayout()
    }
}
