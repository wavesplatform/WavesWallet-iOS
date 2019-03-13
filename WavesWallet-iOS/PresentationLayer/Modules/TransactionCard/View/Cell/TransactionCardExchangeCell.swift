    //
//  TransactionCardExchangeCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 12/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

final class TransactionCardExchangeCell: UITableViewCell, Reusable {

    struct Model {
        
        let sell: BalanceLabel.Model
        let price: BalanceLabel.Model
    }

    @IBOutlet private var sellTitleLabel: UILabel!
    @IBOutlet private var sellBalanceLabel: BalanceLabel!

    @IBOutlet private var priceTitleLabel: UILabel!
    @IBOutlet private var priceBalanceLabel: BalanceLabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        separatorInset = .init(top: 0, left: bounds.width, bottom: 0, right: 0)
    }
}

// TODO: ViewConfiguration

extension TransactionCardExchangeCell: ViewConfiguration {

    func update(with model: TransactionCardExchangeCell.Model) {

        sellTitleLabel.text = "Sell"
        sellBalanceLabel.update(with: model.sell)

        priceTitleLabel.text = "Price"
        priceBalanceLabel.update(with: model.price)
    }
}


