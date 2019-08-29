//
//  ConfirmRequestSkeletonCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 27.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit
import Extensions

final class ConfirmRequestSkeletonCell: SkeletonTableCell, Reusable {
    
    @IBOutlet weak var viewContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.addTableCellShadowStyle()
    }
}


