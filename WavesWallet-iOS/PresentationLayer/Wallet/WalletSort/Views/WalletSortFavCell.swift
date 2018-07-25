//
//  WalletSortFavCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 24.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class WalletSortFavCell: UITableViewCell, Reusable {

    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var buttonFav: UIButton!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var iconLock: UIImageView!
    @IBOutlet weak var arrowGreen: UIImageView!
    @IBOutlet weak var switchControl: UISwitch!
    @IBOutlet weak var labelCryptoName: UILabel!

    func setupCellState(isVisibility: Bool) {
        switchControl.alpha = isVisibility ? 1 : 0
    }

    class func cellHeight() -> CGFloat {
        return 48
    }

}
