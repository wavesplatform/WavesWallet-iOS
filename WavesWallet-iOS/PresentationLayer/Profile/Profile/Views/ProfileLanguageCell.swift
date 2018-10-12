//
//  ProfileLanguageCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 05/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let height: CGFloat = 56
}

final class ProfileLanguageCell: UITableViewCell, Reusable {

    struct Model {
        let languageIcon: UIImage
    }

    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var iconArrow: UIImageView!
    @IBOutlet private weak var iconLanguage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.addTableCellShadowStyle()
    }

    class func cellHeight() -> CGFloat {
        return Constants.height
    }
}

// MARK: ViewConfiguration

extension ProfileLanguageCell: ViewConfiguration {

    func update(with model: ProfileLanguageCell.Model) {
        iconLanguage.image = model.languageIcon
        labelTitle.text = Localizable.Profile.Cell.Language.title
    }
}
