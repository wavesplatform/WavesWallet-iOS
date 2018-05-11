//
//  AssetBalanceCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/1/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class AssetBalanceCell: UITableViewCell {

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var viewLeased: UIView!
    @IBOutlet weak var viewTotal: UIView!
    @IBOutlet weak var viewInOrder: UIView!
    @IBOutlet weak var viewDotterLine: DottedLineView!
    
    
    @IBOutlet weak var heightLeased: NSLayoutConstraint!
    @IBOutlet weak var heightTotal: NSLayoutConstraint!
    @IBOutlet weak var heightInOrder: NSLayoutConstraint!
    
    @IBOutlet weak var labelBalance: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.addTableCellShadowStyle()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    class func cellHeight(isLeased: Bool, inOrder: Bool) -> CGFloat {
        var height : CGFloat = 210
        
        if isLeased {
            height += 44
        }
        if inOrder {
            height += 44
        }
        
        if isLeased || inOrder {
            height += 44
        }
        else {
            height += 10
        }
        
        return height
    }
    
    func setupCell(isLeased: Bool, inOrder: Bool) {
        
        let text = "000.0000000"
        
        labelBalance.attributedText = DataManager.attributedBalanceText(text: text, font: labelBalance.font)

        
        if isLeased {
            heightLeased.constant = 44
            viewLeased.isHidden = false
        }
        else {
            heightLeased.constant = 0
            viewLeased.isHidden = true
        }
        
        if inOrder {
            heightInOrder.constant = 44
            viewInOrder.isHidden = false
        }
        else {
            heightInOrder.constant = 0
            viewInOrder.isHidden = true
        }
        
        if isLeased || inOrder {
            viewDotterLine.isHidden = true
            heightTotal.constant = 44
            viewTotal.isHidden = false
        }
        else {
            viewDotterLine.isHidden = false
            heightTotal.constant = 10
            viewTotal.isHidden = true
        }
    }
}
