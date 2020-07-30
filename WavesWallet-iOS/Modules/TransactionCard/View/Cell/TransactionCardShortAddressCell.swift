//
//  TransactionCardRecipientCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 11/03/2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import UIKit
import UITools

final class TransactionCardShortAddressCell: UITableViewCell, Reusable {

    @IBOutlet private var copyButton: PasteboardButton!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var addressLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel.font = UIFont.captionRegular
        addressLabel.font = UIFont.captionRegular
        
        titleLabel.textColor = .basic500
        addressLabel.textColor = .black
        
        copyButton.copiedText = { [weak self] in
            guard let self = self else { return nil }
            return self.addressLabel.text ?? ""
        }
    }

    func setTitle(_ title: String) {
        titleLabel.text = title
    }

    func setAddress(_ address: String) {
        addressLabel.text = address
    }
}
