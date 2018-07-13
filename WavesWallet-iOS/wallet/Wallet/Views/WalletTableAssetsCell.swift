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
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelSubtitle: UILabel!
    @IBOutlet var labelCryptoName: UILabel!
    @IBOutlet var viewSpam: UIView!
    @IBOutlet var viewAssetType: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        viewContent.addTableCellShadowStyle()
    }

    class func cellHeight() -> CGFloat {
        // cell height 68 and 8 bottom pading
        return 76
    }

    func setupCell(value: String) {
        labelTitle.text = value
    }
}

extension WalletTableAssetsCell: ViewConfiguration {
    func update(with model: WalletTypes.ViewModel.Asset) {
        let name = model.name
        labelTitle.text = name
        let text = "000.0000000"
        labelSubtitle.attributedText = DataManager.attributedBalanceText(text: text, font: labelSubtitle.font)
        let iconName = DataManager.logoForCryptoCurrency(name)
        if iconName.count == 0 {
            imageIcon.image = nil
            imageIcon.backgroundColor = DataManager.bgColorForCryptoCurrency(name)
            if let symbol = name.uppercased().first {
                labelCryptoName.text = String(symbol)
            }
        } else {
            labelCryptoName.text = nil
            imageIcon.image = UIImage(named: name)
        }
    }
}
