//
//  MyOrdersSkeletonCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 24.12.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Extensions
import UIKit
import UITools

private enum Constants {
    static let height: CGFloat = 90
}

final class MyOrdersSkeletonCell: SkeletonTableCell, NibReusable {
    @IBOutlet private weak var labelType: UILabel!
    @IBOutlet private weak var labelPrice: UILabel!
    @IBOutlet private weak var labelStatus: UILabel!
    @IBOutlet private weak var labelAmount: UILabel!
    @IBOutlet private weak var labelSum: UILabel!

    @IBOutlet private var labels: [UILabel]!

    override func awakeFromNib() {
        super.awakeFromNib()

        setupLocalization()

        for label in labels {
            label.font = UIFont.robotoRegular(size: label.font.pointSize)
        }
    }

    private func setupLocalization() {
        labelAmount.text = Localizable.Waves.Dexmyorders.Label.amount
        labelSum.text = Localizable.Waves.Dexmyorders.Label.sum
        labelType.text = Localizable.Waves.Dexmyorders.Label.type
        labelPrice.text = Localizable.Waves.Dexmyorders.Label.price
        labelStatus.text = Localizable.Waves.Dexmyorders.Label.status
    }
}

extension MyOrdersSkeletonCell: ViewHeight {
    static func viewHeight() -> CGFloat {
        return Constants.height
    }
}
