//
//  TradeSkeletonCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 15.01.2020.
//  Copyright © 2020 Waves.Exchange. All rights reserved.
//

import Extensions
import UIKit
import UITools

private enum Constants {
    static let height: CGFloat = 70
}

final class TradeSkeletonCell: SkeletonTableCell, NibReusable {
    @IBOutlet private weak var viewContainer: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.addTableCellShadowStyle()
    }
}

extension TradeSkeletonCell: ViewHeight {
    static func viewHeight() -> CGFloat { Constants.height }
}
