//
//  AssetSkeletonCell.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 17/07/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

final class WalletAssetSkeletonCell: SkeletonCell, Reusable {
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
