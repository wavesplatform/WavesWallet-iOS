//
//  AssetEmptyHistoryCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/7/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Extensions
import UIKit
import UITools

final class AssetEmptyHistoryCell: UITableViewCell, NibReusable {
    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var labelTitle: UILabel!

    class func cellHeight() -> CGFloat { 56 }
}

extension AssetEmptyHistoryCell: ViewConfiguration {
    func update(with model: String) {
        labelTitle.text = model
    }
}
