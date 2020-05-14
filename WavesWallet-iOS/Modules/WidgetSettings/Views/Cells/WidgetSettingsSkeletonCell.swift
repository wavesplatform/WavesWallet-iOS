//
//  WidgetSettingsSkeletonCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 06.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Extensions
import UIKit
import UITools

final class WidgetSettingsSkeletonCell: SkeletonTableCell, Reusable {
    @IBOutlet private weak var viewContainer: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.addTableCellShadowStyle()
    }
}
