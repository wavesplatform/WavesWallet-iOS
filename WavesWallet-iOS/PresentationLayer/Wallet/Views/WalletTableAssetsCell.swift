//
//  WalletTableCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/29/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class WalletTableAssetsCell: UITableViewCell, Reusable {
    @IBOutlet var imageIcon: UIImageView!
    @IBOutlet var viewContent: UIView!
    @IBOutlet var iconArrow: UIImageView!
    @IBOutlet var iconStar: UIImageView!
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelSubtitle: UILabel!
    @IBOutlet var labelCryptoName: UILabel!
    @IBOutlet var viewFiatBalance: UIView!
    @IBOutlet var viewSpam: UIView!
    @IBOutlet var viewAssetType: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        viewContent.addTableCellShadowStyle()
    }

    class func cellHeight() -> CGFloat {
        return 76
    }
}

extension WalletTableAssetsCell: ViewConfiguration {
    func update(with model: WalletTypes.DTO.Asset) {
        let name = model.name
        labelTitle.text = name

        viewSpam.isHidden = true
        iconStar.isHidden = !model.isFavorite
        viewFiatBalance.isHidden = true
        iconArrow.isHidden = !model.isFiat
        viewSpam.isHidden = model.kind != .spam
        let text = model.balance.displayTextFull

        labelSubtitle.attributedText = NSAttributedString.styleForBalance(text: text, font: labelSubtitle.font)
        let iconName = DataManager.logoForCryptoCurrency(name)
        if iconName.count == 0 {
            imageIcon.image = nil
            imageIcon.backgroundColor = DataManager.bgColorForCryptoCurrency(name)
            if let symbol = name.uppercased().first {
                labelCryptoName.text = String(symbol)
            }
        } else {
            labelCryptoName.text = nil
            imageIcon.backgroundColor = .clear
            imageIcon.image = UIImage(imageLiteralResourceName: iconName)
        }
    }
}
