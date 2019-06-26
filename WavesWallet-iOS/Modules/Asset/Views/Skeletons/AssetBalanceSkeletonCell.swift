//
//  AssetBalanceSkeletonCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 16.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

fileprivate enum Constants {
    static var height: CGFloat = 258
}

final class AssetBalanceSkeletonCell: SkeletonTableCell, NibReusable {
    
    @IBOutlet var viewContent: UIView!
    @IBOutlet var separatorViews: [SeparatorView]!

    override func awakeFromNib() {
        super.awakeFromNib()
        viewContent.addTableCellShadowStyle()
        backgroundColor = UIColor.basic50
        separatorViews.forEach { $0.lineColor = .accent100 }
    }

    class func cellHeight() -> CGFloat {
        return Constants.height
    }
}
