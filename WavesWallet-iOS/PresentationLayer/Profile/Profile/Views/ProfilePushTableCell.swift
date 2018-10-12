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

final class ProfilePushTableCell: UITableViewCell, Reusable, ViewConfiguration {
    typealias Model = Void

    @IBOutlet private weak var titleLabel: UILabel!

    class func cellHeight() -> CGFloat {
        return Constants.height
    }

    func update(with model: Void) {
        titleLabel.text = Localizable.Profile.Cell.Pushnotifications.title
    }
}
