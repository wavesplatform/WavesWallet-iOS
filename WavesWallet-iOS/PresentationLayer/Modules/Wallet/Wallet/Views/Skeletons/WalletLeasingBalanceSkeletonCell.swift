//
//  WalletLeasingBalanceSkeletonCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 17.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

private enum Constants {
    static let height: CGFloat = 290
}

final class WalletLeasingBalanceSkeletonCell: SkeletonTableCell, Reusable {
    @IBOutlet var viewContent: UIView!    
    @IBOutlet var separatorViews: [SeparatorView]!

    override func awakeFromNib() {
        super.awakeFromNib()
        viewContent.addTableCellShadowStyle()
        separatorViews.forEach { $0.lineColor = .accent100 }
        backgroundColor = UIColor.basic50
    }

    class func cellHeight() -> CGFloat {
        return Constants.height
    }
}
