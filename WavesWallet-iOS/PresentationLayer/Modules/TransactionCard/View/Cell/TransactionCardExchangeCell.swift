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

        enum Kind {
            case sell(BalanceLabel.Model)
            case buy(BalanceLabel.Model)
        }

        let amount: Kind
        let price: BalanceLabel.Model
    }

    @IBOutlet private var firstTitleLabel: UILabel!
    @IBOutlet private var firstBalanceLabel: BalanceLabel!

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

        switch model.amount {
        case .buy(let model):
            firstTitleLabel.text = Localizable.Waves.Transactioncard.Title.Exchange.buy
            firstBalanceLabel.update(with: model)

        case .sell(let model):
            firstTitleLabel.text = Localizable.Waves.Transactioncard.Title.Exchange.sell
            firstBalanceLabel.update(with: model)
        }

        priceTitleLabel.text = Localizable.Waves.Transactioncard.Title.price
        priceBalanceLabel.update(with: model.price)
    }
}


