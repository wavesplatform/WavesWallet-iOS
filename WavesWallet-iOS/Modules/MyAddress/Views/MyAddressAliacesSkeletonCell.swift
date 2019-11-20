//
//  AddressesKeysSkeletonCell.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 27/10/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit
import Extensions

private enum Constants {
    static let height: CGFloat = 108
}

final class MyAddressAliacesSkeletonCell: SkeletonTableCell, Reusable {

    @IBOutlet var viewContent: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

// MARK: ViewCalculateHeight

extension MyAddressAliacesSkeletonCell: ViewHeight {

    static func viewHeight() -> CGFloat {
        return Constants.height
    }
}
