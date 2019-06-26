//
//  AssetSelectSkeletonView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/8/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class AssetSelectSkeletonView: SkeletonView, NibOwnerLoadable  {

    @IBOutlet private weak var iconArrows: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }
    
    func startAnimation(showArrows: Bool) {
        isHidden = false
        iconArrows.isHidden = !showArrows
        startAnimation()
    }
    
    func hide() {
        isHidden = true
        stopAnimation()
    }
}
