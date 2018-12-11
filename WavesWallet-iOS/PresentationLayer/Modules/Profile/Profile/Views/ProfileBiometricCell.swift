//
//  ProfileBiometricCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 05/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let height: CGFloat = 56
}

final class ProfileBiometricCell: UITableViewCell, Reusable {

    struct Model {
        let isOnBiometric: Bool
    }

    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var switchControl: UISwitch!

    var switchChangedValue: ((Bool) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.addTableCellShadowStyle()
    }

    class func cellHeight() -> CGFloat {
        return Constants.height
    }
}

// MARK: Action

private extension ProfileBiometricCell {

    @IBAction func changedValue(sender: UISwitch) {
        switchChangedValue?(sender.isOn)
    }
}

// MARK: ViewConfiguration

extension ProfileBiometricCell: ViewConfiguration {

    func update(with model: ProfileBiometricCell.Model) {
        labelTitle.text = BiometricType.biometricByDevice.title
        switchControl.isOn = model.isOnBiometric
    }
}
