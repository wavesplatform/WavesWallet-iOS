//
//  WalletSortCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 24.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class WalletSortCell: UITableViewCell {

    @IBOutlet weak var buttonFav: UIButton!
    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var arrowGreen: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var iconMenu: UIImageView!
    @IBOutlet weak var switchControl: UISwitch!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var labelCryptoName: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        viewContent.addTableCellShadowStyle()
    }

    class func cellHeight() -> CGFloat {
        return 56
    }

    func setupCellState(isVisibility: Bool) {
        switchControl.alpha = isVisibility ? 1 : 0
        iconMenu.alpha = isVisibility ? 0 : 1

        iconMenu.alpha = 0
    }
}
