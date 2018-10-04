//
//  ProfileBackupPhraseCell.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 03/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class ProfileBackupPhraseCell: UITableViewCell {

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var viewColorState: UIView!
    @IBOutlet weak var iconState: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.addTableCellShadowStyle()

        let maskPath = UIBezierPath(roundedRect: viewColorState.bounds, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: 3, height: 3))
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        viewColorState.layer.mask = shape
    }
}
