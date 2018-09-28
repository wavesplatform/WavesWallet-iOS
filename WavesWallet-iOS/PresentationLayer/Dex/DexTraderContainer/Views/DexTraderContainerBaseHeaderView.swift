//
//  DexTraderContainerBaseHeaderView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/22/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let cornerRadius: CGFloat = 3
}

class DexTraderContainerBaseHeaderView: UIView {

    override func layoutSubviews() {
        super.layoutSubviews()
        createTopCorners(radius: Constants.cornerRadius)
    }
    
    func setWhiteState() {
        backgroundColor = .white
        subviews.forEach{ $0.isHidden = true }
    }
    
    func setDefaultState() {
        backgroundColor = .basic50
        subviews.forEach{ $0.isHidden = false }
    }
}
