//
//  AssetEmptyHistoryCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/7/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class AssetEmptyHistoryCell: UITableViewCell, Reusable {

    @IBOutlet weak var viewContainer: UIView!

    class func cellHeight() -> CGFloat {
        return 56
    }
}
