//
//  TransactionCardRecipientCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 11/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

final class TransactionCardAddressCell: UITableViewCell, Reusable {

    struct Model {
        let contactDetail: ContactDetailView.Model
        let isSpam: Bool
        let isEditName: Bool
    }

    @IBOutlet private var contactDetailView: ContactDetailView!

    @IBOutlet private var copyButton: PasteboardButton!

    @IBOutlet private var addressBookButton: AddressBookButton!

    @IBOutlet private var spamView: TickerView!

    @IBOutlet private var stackView: UIStackView!

    private var model: Model?

    var handlerTapAddressBook: ((_ needAddAddress: Bool) -> Void)? = nil

    override func awakeFromNib() {
        super.awakeFromNib()

        copyButton.copiedText = { [weak self] in
            return self?.model?.contactDetail.address
        }
        spamView.update(with: TickerView.spamTicker)
        setHiddenSpam(true)
    }

    private func setHiddenSpam(_ isHidden: Bool) {
        addressBookButton.isHidden = !isHidden
        spamView.isHidden = isHidden
    }

    @IBAction func actionAddressBookButton(_ sender: Any) {
        handlerTapAddressBook?(model?.isEditName ?? false)
    }
}

// TODO: ViewConfiguration

extension TransactionCardAddressCell: ViewConfiguration {

    func update(with model: Model) {

        self.model = model

        contactDetailView.update(with: model.contactDetail)
        if model.isEditName {
            addressBookButton.update(with: .edit)
        } else {
            addressBookButton.update(with: .add)
        }
        setHiddenSpam(!model.isSpam)
    }
}

