//
//  WidgetSettingsSkeletonCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 06.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit
import Extensions

final class WidgetSettingsSkeletonCell: SkeletonTableCell, Reusable {
    
    @IBOutlet weak var viewContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.addTableCellShadowStyle()
    }
}

