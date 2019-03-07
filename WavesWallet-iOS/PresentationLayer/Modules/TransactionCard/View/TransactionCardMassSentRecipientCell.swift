//
//  TransactionCardMassSentRecipientCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 07/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

final class TransactionCardMassSentRecipientCell: UITableViewCell, Reusable {

    private enum Info {
        case balance(BalanceLabel.Model)
        case label(String)
    }

    @IBOutlet private var contactDetailView: ContactDetailView!

    @IBOutlet private var balanceLabel: BalanceLabel!

    @IBOutlet private var copyButton: UIButton!

    @IBOutlet private var addressBookButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        let money = Money(100334, 3)

        let balance = Balance.init(currency: Balance.Currency.init(title: "Waves",
                                                                   ticker: "Waves Log"),
                                   money: money)
        balanceLabel.update(with: BalanceLabel.Model.init(balance: balance,
                                                          sign: .plus,
                                                          style: .small))

        contactDetailView.update(with: .init(title: "Rec kaey",
                                            address:. init(address: "asdas dasda23e 234 2",
                                            contact: nil,
            isMyAccount: false,
            aliases: [])))

    }
}

// TODO: ViewConfiguration

extension TransactionCardMassSentRecipientCell: ViewConfiguration {

    func update(with model: DomainLayer.DTO.SmartTransaction) {

//        transactionImageView.update(with: model.kind)
        //TODO: Mapping
    }
}
