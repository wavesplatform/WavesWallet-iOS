//
//  AssetViewHistorySkeletonCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 16.08.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Extensions
import Foundation
import UIKit
import UITools

fileprivate enum Constants {
    static var height: CGFloat = 56
}

final class AssetHistorySkeletonCell: SkeletonTableCell, NibReusable {
    @IBOutlet var viewContent: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        viewContent.addTableCellShadowStyle()
        backgroundColor = UIColor.basic50
    }

    class func cellHeight() -> CGFloat { Constants.height }
}
