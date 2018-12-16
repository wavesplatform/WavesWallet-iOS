//
//  AssetTransactionSkeletonCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 16.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

fileprivate enum Constants {
    static var height: CGFloat = 76
}

final class AssetTransactionSkeletonCell: SkeletonTableCell, NibReusable {
    @IBOutlet var viewContent: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        viewContent.addTableCellShadowStyle()
        backgroundColor = UIColor.basic50
    }

    class func cellHeight() -> CGFloat {
        return Constants.height
    }
}
