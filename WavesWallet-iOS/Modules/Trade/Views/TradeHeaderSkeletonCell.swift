//
//  TradeHeaderSkeletonCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 15.01.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import Extensions

private enum Constants {
    static let height: CGFloat = 38
}

final class TradeHeaderSkeletonCell: SkeletonTableCell, NibReusable {

    override func awakeFromNib() {
        super.awakeFromNib()

    }
}

extension TradeHeaderSkeletonCell: ViewHeight {
    
    static func viewHeight() -> CGFloat {
        return Constants.height
    }
}
