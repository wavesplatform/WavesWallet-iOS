//
//  BuyCryptoSkeletonView.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 25.05.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UITools
import UIKit

final class BuyCryptoSkeletonView: UIView, NibLoadable, ResetableView {
    override func awakeFromNib() {
        super.awakeFromNib()
        resetToEmptyState()
        initialSetup()
    }
    
    func resetToEmptyState() {
        
    }
    
    private func initialSetup() {
        
    }
}
