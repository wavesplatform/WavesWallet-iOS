//
//  ProfileBottomCell.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 03/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let height: CGFloat = 258
}

final class ProfileInfoCell: UITableViewCell, Reusable {

    struct Model {
        let version: String
        let height: String?
        let isLoadingHeight: Bool
    }
    
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var logoutButton: UIButton!

    @IBOutlet private weak var currentHeightTitleLabel: UILabel!
    @IBOutlet private weak var versionTitleLabel: UILabel!

    @IBOutlet private weak var currentHeightValueLabel: UILabel!
    @IBOutlet private weak var versionValueLabel: UILabel!

    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!

    var logoutButtonDidTap: (() -> Void)?
    var deleteButtonDidTap: (() -> Void)?

    class func cellHeight() -> CGFloat {
        return Constants.height
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        deleteButton.setBackgroundImage(UIColor.error400.image, for: .normal)
        deleteButton.setBackgroundImage(UIColor.error200.image, for: .highlighted)
        deleteButton.setBackgroundImage(UIColor.error100.image, for: .disabled)

        deleteButton.setTitle(Localizable.Profile.Button.Delete.title, for: .normal)
        logoutButton.setTitle(Localizable.Profile.Button.Logout.title, for: .normal)

        currentHeightTitleLabel.text = Localizable.Profile.Cell.Info.Currentheight.title
        versionTitleLabel.text = Localizable.Profile.Cell.Info.Version.title
    }
}


// MARK: Action

private extension ProfileInfoCell {

    @IBAction func deleteAccount(sender: UIButton) {
        deleteButtonDidTap?()
    }

    @IBAction func logoutAccount(sender: UIButton) {
        logoutButtonDidTap?()
    }
}

// MARK: ViewConfiguration

extension ProfileInfoCell: ViewConfiguration {

    func update(with model: ProfileInfoCell.Model) {
        currentHeightValueLabel.text = model.height
        versionValueLabel.text = model.version

        if model.isLoadingHeight {
            activityIndicatorView.startAnimating()
        } else {
            activityIndicatorView.stopAnimating()
        }
    }
}

