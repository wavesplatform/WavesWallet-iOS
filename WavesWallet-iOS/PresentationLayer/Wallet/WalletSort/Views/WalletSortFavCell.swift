//
//  WalletSortFavCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 24.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class WalletSortFavCell: UITableViewCell, Reusable {
    @IBOutlet var imageIcon: UIImageView!
    @IBOutlet var buttonFav: UIButton!
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var iconLock: UIImageView!
    @IBOutlet var arrowGreen: UIImageView!
    @IBOutlet var switchControl: UISwitch!
    @IBOutlet var labelCryptoName: UILabel!

    class func cellHeight() -> CGFloat {
        return 48
    }
}

extension WalletSortFavCell: ViewConfiguration {
    struct Model {
        let name: String
        let isMyAsset: Bool
        let isLock: Bool
        let isVisibility: Bool
    }

    func update(with model: WalletSortFavCell.Model) {
        let cryptoName = model.name
        labelTitle.text = cryptoName
        switchControl.isHidden = !model.isVisibility

        let iconName = DataManager.logoForCryptoCurrency(cryptoName)
        if iconName.count == 0 {
            labelCryptoName.text = String(cryptoName.first!).uppercased()
            imageIcon.image = nil
            imageIcon.backgroundColor = DataManager.bgColorForCryptoCurrency(cryptoName)
        } else {
            labelCryptoName.text = nil
            imageIcon.image = UIImage(named: iconName)
        }

        iconLock.isHidden = model.isLock
    }
}
