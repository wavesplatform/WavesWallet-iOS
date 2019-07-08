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
        let contact: DomainLayer.DTO.Contact?
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

    var tapAddressBookButton: ((_ isAddAddress: Bool) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        copyButton.copiedText = { [weak self] in
            guard let self = self else { return nil }
            return self.model?.contactDetail.address
        }
        spamView.update(with: TickerView.spamTicker)
        setHiddenSpam(true)
    }

    private func setHiddenSpam(_ isHidden: Bool) {
        addressBookButton.isHidden = !isHidden
        spamView.isHidden = isHidden
    }

    @IBAction private func actionAddressBookButton(_ sender: Any) {
        tapAddressBookButton?(!(model?.isEditName ?? false))
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

