//
//  WalletLeasingCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/29/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class WalletLeasingCell: UITableViewCell {

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.addTableCellShadowStyle()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    class func cellHeight() -> CGFloat {
        return 76
    }
    
    func setupCell(_ title: String) {
        labelTitle.attributedText = DataManager.attributedBalanceText(text: title, font: labelTitle.font)
    }
}
