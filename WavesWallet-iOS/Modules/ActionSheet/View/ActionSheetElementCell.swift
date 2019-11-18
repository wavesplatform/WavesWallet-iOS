//
//  ActionSheetElementCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 02.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import UIKit
import Extensions

final class ActionSheetElementCell: UITableViewCell, Reusable {
    
    struct Model {
        let title: String
        let isSelected: Bool
    }
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var iconImageView: UIImageView!
}

extension ActionSheetElementCell: ViewConfiguration {
    
    func update(with model: ActionSheetElementCell.Model) {
        titleLabel.text = model.title
        
        if model.isSelected {
            iconImageView.image = Images.on.image
        } else {
            iconImageView.image = Images.off.image
        }
    }
}
