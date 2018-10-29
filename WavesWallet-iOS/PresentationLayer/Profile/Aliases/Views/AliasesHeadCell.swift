//
//  AliasesHeadCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 29/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let height: CGFloat = 156
}

final class AliasesHeadCell: UITableViewCell, Reusable {

    @IBOutlet private var viewContainer: UIView!
    @IBOutlet private var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupLocalization()
    }
}

// MARK: ViewCalculateHeight

extension AliasesHeadCell: ViewCalculateHeight {

    static func viewHeight(model: Void, width: CGFloat) -> CGFloat {
        return Constants.height
    }
}

// MARK: Localization

extension AliasesHeadCell: Localization {

    func setupLocalization() {

    }
}
