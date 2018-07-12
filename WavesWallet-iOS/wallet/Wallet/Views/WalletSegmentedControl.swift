//
//  WalletSegmentedControl.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 12.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

final class WalletSegmentedControl: UIView {
    @IBOutlet var segmentedControl: SegmentedControl!

    override func awakeFromNib() {
        super.awakeFromNib()
        segmentedControl.backgroundColor = .basic50
        backgroundColor = .basic50
        segmentedControl.update(with: [SegmentedControl.Button(name: "Assets"),
                                       SegmentedControl.Button(name: "Leasing")],
                                animated: true)
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: segmentedControl.intrinsicContentSize.height + 18 * 2)
    }
}
