//
//  TransactionCardKeyValueCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 11/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

final class TransactionCardKeyValueCell: UITableViewCell, Reusable {

    struct Model {
        let key: String
        let value: String
    }

    @IBOutlet private var keyLabel: UILabel!
    @IBOutlet private var valueLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        separatorInset = .init(top: 0, left: self.bounds.width, bottom: 0, right: 0)
    }
}

// TODO: ViewConfiguration

extension TransactionCardKeyValueCell: ViewConfiguration {

    func update(with model: TransactionCardKeyValueCell.Model) {

        keyLabel.text = model.key
        valueLabel.text = model.value
    }
}
