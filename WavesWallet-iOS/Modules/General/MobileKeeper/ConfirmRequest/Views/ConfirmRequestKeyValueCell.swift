//
//  ConfirmRequestKeyValueCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 27.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Extensions
import Foundation
import UIKit
import UITools

final class ConfirmRequestKeyValueCell: UITableViewCell, Reusable {
    struct Model {
        let title: String
        let value: String
    }

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var valueLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = UIView()
        selectionStyle = .none
    }
}

// MARK: ViewConfiguration

extension ConfirmRequestKeyValueCell: ViewConfiguration {
    func update(with model: Model) {
        titleLabel.text = model.title
        valueLabel.text = model.value
    }
}
