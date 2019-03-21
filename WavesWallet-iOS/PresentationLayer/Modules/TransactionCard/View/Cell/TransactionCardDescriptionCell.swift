//
//  TransactionCardDescriptionCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 12/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

final class TransactionCardDescriptionCell: UITableViewCell, Reusable {

    struct Model {
        let description: String
    }

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        separatorInset = .init(top: 0, left: self.bounds.width, bottom: 0, right: 0)
    }
}

// TODO: ViewConfiguration

extension TransactionCardDescriptionCell: ViewConfiguration {

    func update(with model: TransactionCardDescriptionCell.Model) {

        titleLabel.text = Localizable.Waves.Transactioncard.Title.description
        descriptionLabel.text = model.description
    }
}


