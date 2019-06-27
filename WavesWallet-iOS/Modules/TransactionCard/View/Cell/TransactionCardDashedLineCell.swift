//
//  TransactionCardDashedLineCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 12/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

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

    @IBOutlet var topLayoutConstaint: NSLayoutConstraint!
    @IBOutlet var bottomLayoutConstaint: NSLayoutConstraint!

    override func updateConstraints() {

        guard let model = model else { return }

        switch model {
        case .bottomPadding:
            self.topLayoutConstaint.constant = 0
            self.bottomLayoutConstaint.constant = Constants.padding

        case .topPadding:
            self.topLayoutConstaint.constant = Constants.padding
            self.bottomLayoutConstaint.constant = 0

        case .nonePadding:
            self.topLayoutConstaint.constant = 0
            self.bottomLayoutConstaint.constant = 0
        }

        super.updateConstraints()
    }

    func update(with model: TransactionCardDashedLineCell.Model) {
        self.model = model
        needsUpdateConstraints()
    }
}
