//
//  AmountSkeletonView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/9/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Extensions
import UIKit
import UITools

final class AmountSkeletonView: SkeletonView, NibOwnerLoadable {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }

    func start() {
        isHidden = false
        startAnimation()
    }

    func stop() {
        isHidden = true
        stopAnimation()
    }
}
