//
//  StakingTransferDescriptionCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 22.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Extensions
import Foundation
import TTTAttributedLabel
import UIKit
import UITools

final class StakingTransferDescriptionCell: UITableViewCell, NibReusable {
    @IBOutlet private var titleLabel: TTTAttributedLabel!

    var didSelectLinkWith: ((URL) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel.activeLinkAttributes = NSMutableAttributedString.urlAttributted()
        titleLabel.linkAttributes = NSMutableAttributedString.urlAttributted()
        titleLabel.delegate = self
    }
}

// MARK: ViewConfiguration

extension StakingTransferDescriptionCell: ViewConfiguration {
    func update(with model: NSAttributedString) {
        titleLabel.text = model
        titleLabel.addLinks(from: model)
    }
}

// MARK: TTTAttributedLabelDelegate

extension StakingTransferDescriptionCell: TTTAttributedLabelDelegate {
    func attributedLabel(_: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        guard let url = url else { return }

        didSelectLinkWith?(url)
    }
}
