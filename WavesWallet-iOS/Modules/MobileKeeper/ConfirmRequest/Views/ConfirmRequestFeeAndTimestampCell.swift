//
//  ConfirmRequestFeeAndTimestampCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 27.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit
import Extensions

private enum Constants {
    
}

final class ConfirmRequestFeeAndTimestampCell: UITableViewCell, Reusable {
    
    struct Model {
        let date: Date
        let feeBalance: BalanceLabel.Model
    }

    @IBOutlet private var feeTitleLabel: UILabel!
    @IBOutlet private var balanceLabel: BalanceLabel!
    
    @IBOutlet private var timeTitleLabel: UILabel!
    @IBOutlet private var timeValueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = UIView()
        selectionStyle = .none
    }
}

// MARK: ViewConfiguration

extension ConfirmRequestFeeAndTimestampCell: ViewConfiguration {
    
    func update(with model: Model) {
//        self.titleLabel.text = model.title
//        self.valueLabel.text = model.value
    }
}



