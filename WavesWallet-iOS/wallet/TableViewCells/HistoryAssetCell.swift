//
//  HistoryAssetCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/10/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class HistoryAssetCell: UITableViewCell {

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var labelValue: UILabel!
    
    
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
    
    func setupCell(value: String) {
        
        labelValue.attributedText = DataManager.attributedBalanceText(text: value, font: labelValue.font)
    }
}
