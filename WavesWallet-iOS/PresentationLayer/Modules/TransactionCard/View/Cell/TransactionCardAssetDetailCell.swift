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

//TODO: Loc
        titleLabel.text = "Asset ID"
        assetIdLabel.text = model.assetId

        if model.isReissuable != nil {
            if let isReissuable = model.isReissuable, isReissuable == true {
                reissuableLabel.text = "Reissuable"
            } else {
                reissuableLabel.text = "Not Reissuable"
            }
            reissuableLabel.isHidden = false
        } else {
            reissuableLabel.isHidden = true
        }
    }
}
