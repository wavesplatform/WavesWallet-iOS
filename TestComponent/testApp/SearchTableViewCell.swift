//
//  SearchTableViewCell.swift
//  testApp
//
//  Created by Pavel Gubin on 5/27/19.
//  Copyright © 2019 Pavel Gubin. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    var searchBlockTapped:(() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func searchTapped(_ sender: Any) {
        searchBlockTapped?()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static var cellHeight: CGFloat {
        return 56
    }
}
