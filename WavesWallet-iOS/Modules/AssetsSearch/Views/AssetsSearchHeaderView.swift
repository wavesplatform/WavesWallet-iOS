//
//  WidgetSettingsHeader.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 29.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit

private struct Constants {}

final class WidgetSettingsHeaderView: UITableViewHeaderFooterView, NibReusable {
    
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelAmount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }
}

