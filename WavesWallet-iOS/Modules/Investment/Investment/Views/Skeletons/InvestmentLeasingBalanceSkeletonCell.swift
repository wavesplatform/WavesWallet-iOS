//
//  InvestmentLeasingBalanceSkeletonCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 17.07.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Extensions
import Foundation
import UIKit
import UITools

private enum Constants {
    static let height: CGFloat = 290
}

final class InvestmentLeasingBalanceSkeletonCell: SkeletonTableCell, NibReusable {
    @IBOutlet private weak var viewContent: UIView!
    @IBOutlet private var separatorViews: [SeparatorView]!

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
