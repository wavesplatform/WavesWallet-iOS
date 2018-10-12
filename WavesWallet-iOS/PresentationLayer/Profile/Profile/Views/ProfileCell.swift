//
//  ProfileTableCell.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 03/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class ProfileValueCell: UITableViewCell {

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconLang: UIImageView!
    @IBOutlet weak var switchControl: UISwitch!
    @IBOutlet weak var iconArrow: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.addTableCellShadowStyle()
    }

    class func cellHeight() -> CGFloat {
        return 56
    }

    @IBAction func switchChanged(_ sender: Any) {

        if BiometricManager.type == .none {

            firstAvailableViewController().presentBasicAlertWithTitle(title: "Please setup your \(BiometricManager.touchIDTypeText)")
            DataManager.setUseTouchID(false)
            DispatchQueue.main.async {
                self.switchControl.isOn = false
            }
        }
        else {
            DataManager.setUseTouchID(switchControl.isOn)
        }
    }
}
