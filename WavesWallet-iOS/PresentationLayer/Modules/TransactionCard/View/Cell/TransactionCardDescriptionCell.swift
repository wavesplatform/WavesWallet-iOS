//
//  TransactionCardDescriptionCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 12/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

final class TransactionCardDescriptionCell: UITableViewCell, Reusable {

    struct Model {
        let description: String
    }

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var pasteboardButton: PasteboardButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        pasteboardButton.copiedText = { [weak self] in
            return self?.descriptionLabel.text
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        separatorInset = .init(top: 0, left: self.bounds.width, bottom: 0, right: 0)
    }
}

// TODO: ViewConfiguration

extension TransactionCardDescriptionCell: ViewConfiguration {

    func update(with model: TransactionCardDescriptionCell.Model) {

        //TODO: Localization
        titleLabel.text = "Description"
        descriptionLabel.text = model.description
    }
}


