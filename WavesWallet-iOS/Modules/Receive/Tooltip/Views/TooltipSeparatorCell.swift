//
//  TooltipSeparatorCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 11.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Extensions
import UIKit
import UITools

final class TooltipSeparatorCell: UITableViewCell, Reusable {
    @IBOutlet private var separatorView: SeparatorView!

    override func awakeFromNib() {
        super.awakeFromNib()
        separatorView.lineColor = UIColor.accent100
    }
}
