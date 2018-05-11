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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewContent.addTableCellShadowStyle()
    }
    
    class func cellHeight() -> CGFloat {
        return 76
    }
    
    func setupCell() {
        
        let text = "000.0000000"
        labelSubtitle.attributedText = DataManager.attributedBalanceText(text: text, font: labelSubtitle.font)
    }
}
