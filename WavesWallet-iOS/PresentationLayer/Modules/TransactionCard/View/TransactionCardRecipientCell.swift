//
//  TransactionCardRecipientCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 11/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

final class TransactionCardRecipientCell: UITableViewCell, Reusable {

    @IBOutlet private var contactDetailView: ContactDetailView!

    @IBOutlet private var copyButton: PasteboardButton!

    @IBOutlet private var addressBookButton: AddressBookButton!

    @IBOutlet private var tickerView: TickerView!

    @IBOutlet private var stackView: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()

        contactDetailView.update(with: .init(title: "Rec kaey",
                                             address:. init(address: "asdas dasda23e 234 2",
                                                            contact: nil,
                                                            isMyAccount: false,
                                                            aliases: [])))

        //TODO: Remove
        tickerView.update(with: TickerView.spamTicker)
        setHiddenSpam(true)
    }

    private func setHiddenSpam(_ isHidden: Bool) {
        addressBookButton.isHidden = !isHidden
        tickerView.isHidden = isHidden
    }

    //TODO: Copy button
    @IBAction func actionCopyButton(_ sender: Any) {

    }

    @IBAction func actionAddressBookButton(_ sender: Any) {

    }
}

// TODO: ViewConfiguration

extension TransactionCardRecipientCell: ViewConfiguration {

    func update(with model: DomainLayer.DTO.SmartTransaction) {

        //        transactionImageView.update(with: model.kind)
        //TODO: Mapping
    }
}

