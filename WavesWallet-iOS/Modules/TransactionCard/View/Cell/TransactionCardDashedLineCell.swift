//
//  TransactionCardDashedLineCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 12/03/2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Extensions
import Foundation
import UIKit
import UITools

private struct Constants {
    static let padding: CGFloat = 14
}

final class TransactionCardDashedLineCell: UITableViewCell, Reusable, ViewConfiguration {
    enum Model {
        case topPadding
        case bottomPadding
        case nonePadding
    }

    private var model: Model?

    @IBOutlet private var topLayoutConstaint: NSLayoutConstraint!
    @IBOutlet private var bottomLayoutConstaint: NSLayoutConstraint!

    override func updateConstraints() {
        guard let model = model else { return }

        switch model {
        case .bottomPadding:
            topLayoutConstaint.constant = 0
            bottomLayoutConstaint.constant = Constants.padding

        case .topPadding:
            topLayoutConstaint.constant = Constants.padding
            bottomLayoutConstaint.constant = 0

        case .nonePadding:
            topLayoutConstaint.constant = 0
            bottomLayoutConstaint.constant = 0
        }

        super.updateConstraints()
    }

    func update(with model: TransactionCardDashedLineCell.Model) {
        self.model = model
        needsUpdateConstraints()
    }
}
