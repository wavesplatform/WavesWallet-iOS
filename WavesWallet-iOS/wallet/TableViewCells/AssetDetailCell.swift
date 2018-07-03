//
//  AssetDetailCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/8/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class AssetDetailCell: UITableViewCell {

    @IBOutlet weak var labelIssuer: UILabel!
    @IBOutlet weak var labelID: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func copyIssuerTapped(_ sender: Any) {

        UIPasteboard.general.string = labelIssuer.text

        let button = sender as! UIButton
        button.setImage(UIImage(named: "check_success"), for: .normal)
        button.isUserInteractionEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            button.setImage(UIImage(named: "copy_black"), for: .normal)
            button.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func copyIDTapped(_ sender: Any) {
        
        UIPasteboard.general.string = labelID.text
        
        let button = sender as! UIButton
        button.setImage(UIImage(named: "check_success"), for: .normal)
        button.isUserInteractionEnabled = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            button.setImage(UIImage(named: "copy_black"), for: .normal)
            button.isUserInteractionEnabled = true
        }
    }
    
    class func cellHeight() -> CGFloat {
        
        var offset : CGFloat = 352
        
        let text = "The Waves Platform is a global public blockchain platform, founded in 2016. Waves Platform’s mission is to reinvent the DNA of entrepreneurship around the world by providing a shared infrastructure, offering easy-to-use, highly functional tools to make blockchain available to every person or organisation that can benefit from it."
        offset += text.maxHeight(font: UIFont.systemFont(ofSize: 13), forWidth: Platform.ScreenWidth - 32)
        
        return offset + 24
    }
}
