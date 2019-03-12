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
    }

    @IBOutlet private var titleLabel: UILabel!

    @IBOutlet private var assetIdLabel: UILabel!

    @IBOutlet private var reissuableLabel: UILabel!

    @IBOutlet private var copyButton: PasteboardButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        separatorInset = .init(top: 0, left: self.bounds.width, bottom: 0, right: 0)
    }
}

// TODO: ViewConfiguration

extension TransactionCardAssetDetailCell: ViewConfiguration {

    func update(with model: TransactionCardAssetDetailCell.Model) {

        titleLabel.text = "Asset ID"
        assetIdLabel.text = model.assetId
    }
}
