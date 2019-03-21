//
//  TransactionCardKeyBalanceCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 11/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

final class TransactionCardKeyBalanceCell: UITableViewCell, Reusable {

    struct Model {
        let key: String
        let value: BalanceLabel.Model
    }

    @IBOutlet private var keyLabel: UILabel!
    @IBOutlet private var balanceLabel: BalanceLabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        separatorInset = .init(top: 0, left: bounds.width, bottom: 0, right: 0)
    }
}

// TODO: ViewConfiguration

extension TransactionCardKeyBalanceCell: ViewConfiguration {

    func update(with model: TransactionCardKeyBalanceCell.Model) {

        keyLabel.text = model.key
        balanceLabel.update(with: model.value)
    }
}

