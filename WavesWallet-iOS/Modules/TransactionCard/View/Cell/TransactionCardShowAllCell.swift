//
//  TransactionCardShowAllCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 12/03/2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Extensions
import Foundation
import UIKit
import UITools

final class TransactionCardShowAllCell: UITableViewCell, Reusable {
    struct Model {
        let countOtherTransactions: Int
    }

    @IBOutlet private var buttonShowAll: UIButton!

    var didTapButtonShowAll: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        buttonShowAll.setTitleColor(.submit400,
                                    for: .normal)

        buttonShowAll.setTitleColor(.submit300,
                                    for: .selected)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    @IBAction func actionShowAllButton() {
        didTapButtonShowAll?()
    }
}

// MARK: ViewConfiguration

extension TransactionCardShowAllCell: ViewConfiguration {
    func update(with model: TransactionCardShowAllCell.Model) {
        buttonShowAll.setTitle(Localizable.Waves.Transactioncard.Title.showAll("\(model.countOtherTransactions)"), for: .normal)
    }
}
