//
//  WalletSegmentedControl.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 12.07.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit
import Extensions

private enum Constants {
    static let heightPadding: CGFloat = 36
}

final class WalletSegmentedControl: UIView {
    @IBOutlet var segmentedControl: SegmentedControl!

    override func awakeFromNib() {
        super.awakeFromNib()
        segmentedControl.backgroundColor = .basic50
        backgroundColor = .basic50
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric,
                      height: segmentedControl.intrinsicContentSize.height + Constants.heightPadding)
    }

    func changedValue() -> Signal<Int> {
        return segmentedControl
            .rx
            .controlEvent(.valueChanged)
            .asSignal()
            .map { [weak self] _ -> Int in
                return self?.segmentedControl.selectedIndex ?? 0
            }
    }
}
