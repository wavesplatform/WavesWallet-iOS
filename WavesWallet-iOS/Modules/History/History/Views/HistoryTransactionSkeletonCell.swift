//
//  HistoryTransactionSkeletonCell.swift
//  WavesWallet-iOS
//
//  Created by Mac on 17/08/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit
import Extensions

final class HistoryTransactionSkeletonCell: SkeletonTableCell, Reusable {
    @IBOutlet var viewContent: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewContent.addTableCellShadowStyle()
        backgroundColor = UIColor.basic50
    }
    
    class func cellHeight() -> CGFloat {
        return 76
    }
}

