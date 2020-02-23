//
//  StakingTransferErrorCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 22.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import Extensions
import UIKit

final class StakingTransferErrorCell: UITableViewCell, NibReusable {
    
    struct Model {
        let title: String
    }
    
    @IBOutlet private var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

// MARK: ViewConfiguration

extension StakingTransferErrorCell: ViewConfiguration {
    
    func update(with model: StakingTransferErrorCell.Model) {
        self.titleLabel.text = model.title
    }
}
