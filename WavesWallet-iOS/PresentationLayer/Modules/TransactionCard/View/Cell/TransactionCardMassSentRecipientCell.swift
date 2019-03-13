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

    struct Model {
        let contactDetail: ContactDetailView.Model
        let balance: BalanceLabel.Model
        let isEditName: Bool
    }

    @IBOutlet private var contactDetailView: ContactDetailView!

    @IBOutlet private var balanceLabel: BalanceLabel!

    @IBOutlet private var copyButton: PasteboardButton!

    @IBOutlet private var addressBookButton: AddressBookButton!

    private var address: String?

    override func awakeFromNib() {
        super.awakeFromNib()

        copyButton.copiedText = { [weak self] in
            return self?.address
        }
    }

    //TODO: Copy button
    @IBAction func actionAddressBookButton(_ sender: Any) {

    }
}

// TODO: ViewConfiguration

extension TransactionCardMassSentRecipientCell: ViewConfiguration {

    func update(with model: Model) {

        address = model.contactDetail.address
        balanceLabel.update(with: model.balance)
        contactDetailView.update(with: model.contactDetail)

        if model.isEditName {
            addressBookButton.update(with: .edit)
        } else {
            addressBookButton.update(with: .add)
        }
    }
}
