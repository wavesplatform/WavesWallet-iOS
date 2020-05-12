//
//  TooltipElementCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 11.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Extensions
import UIKit
import UITools

private enum Constanst {
    static let sumPaddingsHorizontal: CGFloat = 48
    static let sumPaddingsVertical: CGFloat = 48
}

final class TooltipInfoCell: UITableViewCell, Reusable {
    struct Model {
        let title: String
        let description: String
    }

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

// MARK: ViewConfiguration

extension TooltipInfoCell: ViewConfiguration {
    func update(with model: TooltipInfoCell.Model) {
        titleLabel.text = model.title
        descriptionLabel.text = model.description
    }
}

extension TooltipInfoCell: ViewCalculateHeight {
    static func viewHeight(model: Model, width: CGFloat) -> CGFloat {
        let titleHeight = model.title.maxHeightMultiline(font: UIFont.systemFont(ofSize: 13,
                                                                                 weight: .bold),
                                                         forWidth: width - Constanst.sumPaddingsVertical)

        let descriptionHeight = model.description.maxHeightMultiline(font: UIFont.systemFont(ofSize: 13),
                                                                     forWidth: width - Constanst.sumPaddingsVertical)

        return titleHeight + descriptionHeight + Constanst.sumPaddingsHorizontal
    }
}
