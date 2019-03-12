//
//  TransactionCardGeneralCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 06/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

final class TransactionCardGeneralCell: UITableViewCell, Reusable {

    private enum Info {
        case balance(BalanceLabel.Model)
        case label(String)
    }

    @IBOutlet private var balanceLabel: BalanceLabel!

    @IBOutlet private var titleLabel: UILabel!

    @IBOutlet private var stackViewLabel: UIStackView!

    @IBOutlet private var transactionImageView: TransactionImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        //TODO: Remove
        let money = Money(100334, 3)

        let balance = Balance.init(currency: Balance.Currency.init(title: "Waves",
                                                                   ticker: "Waves Log"),
                                   money: money)
        balanceLabel.update(with: BalanceLabel.Model.init(balance: balance,
                                                          sign: .plus,
                                                          style: .small))

        transactionImageView.update(with: .createdAlias("test"))

        showInfo(.balance(BalanceLabel.Model.init(balance: balance,
                                                  sign: .plus,
                                                  style: .small)))
    }

    private func showInfo(_ info: Info) {
        switch info {
        case .balance(let balance):
            balanceLabel.update(with: balance)
            balanceLabel.isHidden = false
            titleLabel.isHidden = true

        case .label(let text):
            titleLabel.text = text
            balanceLabel.isHidden = true
            titleLabel.isHidden = false
        }
    }
}

// TODO: ViewConfiguration

extension TransactionCardGeneralCell: ViewConfiguration {

    func update(with model: DomainLayer.DTO.SmartTransaction) {

        transactionImageView.update(with: model.kind)
        //TODO: Mapping
    }
}
