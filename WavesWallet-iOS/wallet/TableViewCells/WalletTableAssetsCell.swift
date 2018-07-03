//
//  WalletTableCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/29/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class WalletTableAssetsCell: UITableViewCell {
    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var iconArrow: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSubtitle: UILabel!
    @IBOutlet weak var labelCryptoName: UILabel!
    @IBOutlet weak var viewSpam: UIView!
    @IBOutlet weak var viewAssetType: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewContent.addTableCellShadowStyle()
    }
    
    class func cellHeight() -> CGFloat {
        return 76
    }
    
    func setupCell(value: String) {
        
        let text = "000.0000000"
        labelSubtitle.attributedText = DataManager.attributedBalanceText(text: text, font: labelSubtitle.font)
        labelTitle.text = value
        let iconName = DataManager.logoForCryptoCurrency(value)
        if iconName.count == 0 {
            imageIcon.image = nil
            imageIcon.backgroundColor = DataManager.bgColorForCryptoCurrency(value)
            labelCryptoName.text = String(value.uppercased().first!)
        }
        else {
            labelCryptoName.text = nil
            imageIcon.image = UIImage(named: iconName)
        }
    }
}
