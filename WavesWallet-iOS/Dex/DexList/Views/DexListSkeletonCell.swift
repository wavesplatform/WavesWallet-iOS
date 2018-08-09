//
//  DexListSkeletonCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/25/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class DexListSkeletonCell: SkeletonCell, Reusable {

    @IBOutlet weak var viewContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.addTableCellShadowStyle()
    }
    
    class func cellHeight() -> CGFloat {
        return DexListCell.cellHeight()
    }
    
}
