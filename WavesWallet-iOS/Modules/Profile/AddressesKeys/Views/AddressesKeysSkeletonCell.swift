//
//  AddressesKeysSkeletonCell.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 27/10/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Extensions
import UIKit
import UITools

private enum Constants {
    static let height: CGFloat = 60
}

final class AddressesKeysSkeletonCell: SkeletonTableCell, Reusable {
    @IBOutlet private var viewContent: UIView!
}

// MARK: ViewHeight

extension AddressesKeysSkeletonCell: ViewHeight {
    static func viewHeight() -> CGFloat { Constants.height }
}
