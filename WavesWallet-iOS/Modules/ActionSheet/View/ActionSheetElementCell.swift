//
//  ActionSheetElementCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 02.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit
import Extensions


final class ActionSheetElementCell: UITableViewCell, Reusable {
    
    struct Model {
        let title: String
        let isSelected: Bool
        let isBlocked: Bool
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
        
        titleLabel.alpha = model.isBlocked ? 0.5 : 1
        iconImageView.alpha = model.isBlocked ? 0.5 : 1
    }
}
