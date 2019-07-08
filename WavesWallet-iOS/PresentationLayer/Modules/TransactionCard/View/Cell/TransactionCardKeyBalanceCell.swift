//
//  TransactionCardKeyBalanceCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 11/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit


private struct Constants {
    static let topPaddingLarge: CGFloat = 24
    static let topPaddingNormal: CGFloat = 14
}

final class TransactionCardKeyBalanceCell: UITableViewCell, Reusable {

    struct Model {

        enum Style {
            case largePadding
            case normalPadding
        }

        let key: String
        let value: BalanceLabel.Model
        let style: Style
    }

    @IBOutlet private var keyLabel: UILabel!
    @IBOutlet private var balanceLabel: BalanceLabel!
    @IBOutlet private var topLayoutConstaint: NSLayoutConstraint!

    private var model: Model?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        separatorInset = .init(top: 0, left: bounds.width, bottom: 0, right: 0)
    }


    override func updateConstraints() {

        guard let model = model else { return }

        switch model.style {
        case .largePadding:
            self.topLayoutConstaint.constant = Constants.topPaddingLarge

        case .normalPadding:
            self.topLayoutConstaint.constant = Constants.topPaddingNormal
        }

        super.updateConstraints()
    }
}

// TODO: ViewConfiguration

extension TransactionCardKeyBalanceCell: ViewConfiguration {

    func update(with model: TransactionCardKeyBalanceCell.Model) {
        self.model = model
        keyLabel.text = model.key
        balanceLabel.update(with: model.value)

        needsUpdateConstraints()
    }
}

