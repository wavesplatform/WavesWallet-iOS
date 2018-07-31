//
//  DexListHeaderCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/31/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class DexListHeaderCell: UITableViewCell, Reusable {

    @IBOutlet weak var labelTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    class func cellHeight() -> CGFloat {
        return 25
    }
   
}
