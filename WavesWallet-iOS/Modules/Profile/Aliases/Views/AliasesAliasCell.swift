//
//  AliasesAliasCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 29/10/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Extensions
import Foundation
import UIKit
import UITools

private enum Constants {
    static let height: CGFloat = 46
}

final class AliasesAliasCell: UITableViewCell, Reusable {
    @IBOutlet private var viewContainer: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var copyButton: PasteboardButton!

    var infoButtonDidTap: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        copyButton.copiedText = { [weak self] in
            self?.titleLabel.text
        }
    }
}

// MARK: ViewConfiguration

extension AliasesAliasCell: ViewConfiguration {
    struct Model {
        let title: String
    }

    func update(with model: AliasesAliasCell.Model) {
        titleLabel.text = model.title
    }
}

// MARK: ViewCalculateHeight

extension AliasesAliasCell: ViewCalculateHeight {
    static func viewHeight(model _: Model, width _: CGFloat) -> CGFloat {
        Constants.height
    }
}
