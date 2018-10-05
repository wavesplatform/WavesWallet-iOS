//
//  ProfilePushTableCell.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 03/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let height: CGFloat = 56
}

final class ProfilePushTableCell: UITableViewCell, Reusable {

    @IBOutlet private weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.text = Localizable.Profile.Cell.Pushnotifications.title
    }

    class func cellHeight() -> CGFloat {
        return Constants.height
    }
}
