//
//  TransactionCardOrderCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 29/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

final class TransactionCardOrderCell: UITableViewCell, Reusable {

    struct Model {
        let amount: BalanceLabel.Model
        let price: BalanceLabel.Model
        let total: BalanceLabel.Model
    }

    @IBOutlet private var amountTitleLabel: UILabel!
    @IBOutlet private var amountBalanceLabel: BalanceLabel!

    @IBOutlet private var priceTitleLabel: UILabel!
    @IBOutlet private var priceBalanceLabel: BalanceLabel!

    @IBOutlet private var totalTitleLabel: UILabel!
    @IBOutlet private var totalBalanceLabel: BalanceLabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        separatorInset = .init(top: 0, left: bounds.width, bottom: 0, right: 0)
    }
}

// TODO: ViewConfiguration

extension TransactionCardOrderCell: ViewConfiguration {

    func update(with model: TransactionCardOrderCell.Model) {

        amountTitleLabel.text = Localizable.Waves.Transactioncard.Title.amount
        amountBalanceLabel.update(with: model.amount)

        priceTitleLabel.text = Localizable.Waves.Transactioncard.Title.price
        priceBalanceLabel.update(with: model.price)

        totalTitleLabel.text = Localizable.Waves.Transactioncard.Title.total
        totalBalanceLabel.update(with: model.total)
    }
}


