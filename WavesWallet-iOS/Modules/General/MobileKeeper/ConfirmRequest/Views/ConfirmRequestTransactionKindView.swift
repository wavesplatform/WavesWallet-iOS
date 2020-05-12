//
//  ConfirmRequestTransactionKindView.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 28.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Extensions
import Foundation
import UIKit
import UITools

final class ConfirmRequestTransactionKindView: UIView, NibOwnerLoadable {
    enum Info {
        case balance(BalanceLabel.Model)
        case descriptionLabel(String)
    }

    struct Model {
        let title: String
        let image: UIImage
        let info: Info
    }

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var infoLabel: UILabel!
    @IBOutlet private var balanceLabel: BalanceLabel!
    @IBOutlet private var iconImageView: UIImageView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

// MARK: ViewConfiguration

extension ConfirmRequestTransactionKindView: ViewConfiguration {
    func update(with model: Model) {
        switch model.info {
        case let .balance(model):
            infoLabel.isHidden = true
            balanceLabel.isHidden = false
            balanceLabel.update(with: model)

        case let .descriptionLabel(text):
            infoLabel.text = text
            infoLabel.isHidden = false
            balanceLabel.isHidden = true
        }

        iconImageView.image = model.image
        titleLabel.text = model.title
    }
}
