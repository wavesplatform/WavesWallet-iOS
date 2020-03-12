//
//  TooltipElementCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 11.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import Extensions

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
