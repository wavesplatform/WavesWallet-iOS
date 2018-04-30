//
//  WalletLeasingTopCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/29/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class WalletLeasingBalanceCell: UITableViewCell {
    
    @IBOutlet weak var viewContainer: UIView!
    
    @IBOutlet weak var labelBalance: UILabel!
    
    @IBOutlet weak var leasedWidth: NSLayoutConstraint!
    @IBOutlet weak var leasedInWidth: NSLayoutConstraint!
    @IBOutlet weak var viewLeasedInHeight: NSLayoutConstraint!
    
    
    class func cellHeight(isAvailableLeasingHistory : Bool) -> CGFloat {
      
        return isAvailableLeasingHistory ? 326 : 296
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.addTableCellShadowStyle()
    }
    
    func setupCell(isAvailableLeasingHistory: Bool) {
        
        let text = "000.0000000"
        
        let range = (text as NSString).range(of: ".")
        let attrString = NSMutableAttributedString(string: text)
        attrString.addAttributes([NSFontAttributeName : UIFont.systemFont(ofSize: labelBalance.font.pointSize, weight: UIFontWeightSemibold)], range: NSRange(location: 0, length: range.location))
        labelBalance.attributedText = attrString
    
        let viewWidth = Platform.ScreenWidth - 32 - 32
        let leasedPercent : CGFloat = 40
        let leasedInPercent : CGFloat = 50
        
        leasedWidth.constant = leasedPercent * viewWidth / 100
        
        leasedInWidth.constant = isAvailableLeasingHistory ? leasedInPercent * viewWidth / 100 : 0
        
        viewLeasedInHeight.constant = isAvailableLeasingHistory ? 40 : 0
    }
}

