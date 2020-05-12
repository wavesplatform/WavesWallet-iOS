//
//  ConfirmRequestTransactionKindCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 27.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Extensions
import Foundation
import UIKit
import UITools

final class ConfirmRequestTransactionKindCell: UITableViewCell, Reusable {
    @IBOutlet private var transactionKindView: ConfirmRequestTransactionKindView!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = UIView()
        selectionStyle = .none
    }
}

// MARK: ViewConfiguration

extension ConfirmRequestTransactionKindCell: ViewConfiguration {
    func update(with model: ConfirmRequestTransactionKindView.Model) {
        transactionKindView.update(with: model)
    }
}
