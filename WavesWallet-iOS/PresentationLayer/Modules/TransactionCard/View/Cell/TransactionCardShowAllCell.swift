//
//  TransactionCardShowAllCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 12/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

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
        update(with: .init(countOtherTransactions: 10))
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    @IBAction func actionShowAllButton() {
        didTapButtonShowAll?()
    }
}

// TODO: ViewConfiguration

extension TransactionCardShowAllCell: ViewConfiguration {

    func update(with model: TransactionCardShowAllCell.Model) {
        buttonShowAll.setTitle("Show all (\(model.countOtherTransactions))", for: .normal)
    }
}
