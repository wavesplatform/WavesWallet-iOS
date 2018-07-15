//
//  WalletQuickNoteCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/29/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class WalletQuickNoteCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    class func cellHeight() -> CGFloat {
        
        let font = UIFont.systemFont(ofSize: 13)
        let text1 = "You can only transfer or trade WAVES that aren’t leased. The leased amount cannot be transferred or traded by you or anyone else."
        let text2 = "You can cancel a leasing transaction as soon as it appears in the blockchain which usually occurs in a minute or less."
        let text3 = "The generating balance will be updated after 1000 blocks."
        
        var height = text1.maxHeight(font: font, forWidth: Platform.ScreenWidth - 16 - 16)
        height += 32
        height += text2.maxHeight(font: font, forWidth: Platform.ScreenWidth - 58 - 16)
        height += 32
        height += text3.maxHeight(font: font, forWidth: Platform.ScreenWidth - 16 - 16)
        return height + 10
    }
}
