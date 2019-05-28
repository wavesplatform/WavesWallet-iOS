//
//  HistoryTransactionCell.swift
//  testApp
//
//  Created by Pavel Gubin on 5/14/19.
//  Copyright © 2019 Pavel Gubin. All rights reserved.
//

import UIKit

class HistoryTransactionCell: UITableViewCell {

    @IBOutlet weak var viewHistory: HistoryTransactionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
