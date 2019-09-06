//
//  ConfirmRequestBalanceCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 27.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit
import Extensions

final class ConfirmRequestBalanceCell: UITableViewCell, Reusable {
    
    struct Model {
        let title: String
        let feeBalance: BalanceLabel.Model
    }
    
    @IBOutlet private var balanceTitleLabel: UILabel!
    @IBOutlet private var balanceLabel: BalanceLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = UIView()
        selectionStyle = .none
    }
}

// MARK: ViewConfiguration

extension ConfirmRequestBalanceCell: ViewConfiguration {
    
    func update(with model: Model) {
        self.balanceTitleLabel.text = model.title
        self.balanceLabel.update(with: model.feeBalance)
    }
}

