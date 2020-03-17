//
//  MinHeightTableViewCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 13.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit

class MinHeightTableViewCell: UITableViewCell {

    var minHeight: CGFloat?

    override func systemLayoutSizeFitting(_ targetSize: CGSize,
                                          withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        
        let size = super.systemLayoutSizeFitting(targetSize,
                                                 withHorizontalFittingPriority: horizontalFittingPriority,
                                                 verticalFittingPriority: verticalFittingPriority)
        
        guard let minHeight = minHeight else { return size }
        
        return CGSize(width: size.width, height: max(size.height, minHeight))
    }
}
