//
//  ProfileBackupPhraseCell.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 03/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let cornerRadii = CGSize(width: 2, height: 2)
    static let height: CGFloat = 56
}

final class ProfileBackupPhraseCell: UITableViewCell, Reusable {

    struct Model {
        let isBackedUp: Bool
    }

    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var viewColorState: UIView!
    @IBOutlet private weak var iconState: UIImageView!
    private let maskForColorState = CAShapeLayer()

    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.addTableCellShadowStyle()
        viewColorState.layer.mask = maskForColorState
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let maskPath = UIBezierPath(roundedRect: viewColorState.bounds,
                                    byRoundingCorners: [.topLeft, .bottomLeft],
                                    cornerRadii: Constants.cornerRadii)
        maskForColorState.path = maskPath.cgPath
    }

    class func cellHeight() -> CGFloat {
        return Constants.height
    }
}

// MARK: ViewConfiguration

extension ProfileBackupPhraseCell: ViewConfiguration {

    func update(with model: ProfileBackupPhraseCell.Model) {
        labelTitle.text = Localizable.Profile.Cell.Backupphrase.title
        if model.isBackedUp {
            viewColorState.backgroundColor = .success400
            iconState.image = Images.check18Success400.image
        } else {
            viewColorState.backgroundColor = .error500
            iconState.image = Images.info18Error500.image
        }
    }
}
