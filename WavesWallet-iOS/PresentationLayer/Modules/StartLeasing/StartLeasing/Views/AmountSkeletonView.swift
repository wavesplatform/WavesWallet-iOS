//
//  AmountSkeletonView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/9/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

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

