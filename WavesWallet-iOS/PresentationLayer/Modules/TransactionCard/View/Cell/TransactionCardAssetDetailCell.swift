//
//  TransactionCardAssetDetailCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 12/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

final class TransactionCardAssetDetailCell: UITableViewCell, Reusable {

    struct Model {
        let assetId: String
        let isReissuable: Bool?
    }

    @IBOutlet private var titleLabel: UILabel!

    @IBOutlet private var assetIdLabel: UILabel!

    @IBOutlet private var reissuableLabel: UILabel!

    @IBOutlet private var copyButton: PasteboardButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        copyButton.isBlack = true
        copyButton.copiedText = { [weak self] in
            return self?.assetIdLabel.text
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        separatorInset = .init(top: 0, left: self.bounds.width, bottom: 0, right: 0)
    }
}

// MARK: ViewConfiguration

extension TransactionCardAssetDetailCell: ViewConfiguration {

    func update(with model: Model) {

        titleLabel.text = Localizable.Waves.Transactioncard.Title.assetId
        assetIdLabel.text = model.assetId

        if model.isReissuable != nil {
            if let isReissuable = model.isReissuable, isReissuable == true {
                reissuableLabel.text = Localizable.Waves.Transactioncard.Title.reissuable
            } else {
                reissuableLabel.text = Localizable.Waves.Transactioncard.Title.notReissuable
            }
            reissuableLabel.isHidden = false
        } else {
            reissuableLabel.isHidden = true
        }
    }
}
