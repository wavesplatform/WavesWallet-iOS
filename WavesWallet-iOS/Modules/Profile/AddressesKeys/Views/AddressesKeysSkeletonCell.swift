//
//  AddressesKeysSkeletonCell.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 27/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let height: CGFloat = 60
}

final class AddressesKeysSkeletonCell: SkeletonTableCell, Reusable {

    @IBOutlet var viewContent: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

// MARK: ViewHeight

extension AddressesKeysSkeletonCell: ViewHeight {

    static func viewHeight() -> CGFloat {
        return Constants.height
    }
}
