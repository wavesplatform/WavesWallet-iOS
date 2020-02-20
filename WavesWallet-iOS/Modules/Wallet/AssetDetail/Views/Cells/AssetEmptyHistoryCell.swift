//
//  AssetEmptyHistoryCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/7/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit
import Extensions

final class AssetEmptyHistoryCell: UITableViewCell, NibReusable {

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var labelTitle: UILabel!
    
    class func cellHeight() -> CGFloat {
        return 56
    }
}

extension AssetEmptyHistoryCell: ViewConfiguration {
    
    func update(with model: String) {
        labelTitle.text = model
    }
}
