//
//  TransactionCardGeneralCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 06/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

final class TransactionCardGeneralCell: UITableViewCell, Reusable {

    struct Model {

        enum Info {
            case balance(BalanceLabel.Model)
            case descriptionLabel(String)
            case status(_ percent: String, status: String?)
        }

        let image: UIImage
        let title: String
        let info: Info
    }

    @IBOutlet private var balanceLabel: BalanceLabel!

    @IBOutlet private var titleLabel: UILabel!

    @IBOutlet private var descriptionLabel: UILabel!

    @IBOutlet private var stackViewLabel: UIStackView!

    @IBOutlet private var transactionImageView: TransactionImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    private func showInfo(_ info: Model.Info) {
        switch info {
        case .balance(let balance):
            balanceLabel.update(with: balance)
            balanceLabel.isHidden = false
            descriptionLabel.isHidden = true

        case .descriptionLabel(let text):

            let attrString = NSMutableAttributedString(string: text,
                                                       attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22,
                                                                                                                   weight: .bold)])

            descriptionLabel.attributedText = attrString
            balanceLabel.isHidden = true
            descriptionLabel.isHidden = false

        case .status(let percent, let status):

            let attrString = NSMutableAttributedString(string: percent,
                                                       attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22,
                                                                                                                   weight: .bold)])


            if let status = status {
                attrString.append(NSMutableAttributedString(string: status,
                                                            attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22,
                                                                                                                        weight: .regular)]))

            }


            descriptionLabel.attributedText = attrString
            balanceLabel.isHidden = true
            descriptionLabel.isHidden = false
        }
    }
}

// TODO: ViewConfiguration

extension TransactionCardGeneralCell: ViewConfiguration {

    func update(with model: TransactionCardGeneralCell.Model) {

        titleLabel.text = model.title
        transactionImageView.update(with: model.image)
        showInfo(model.info)
    }
}
