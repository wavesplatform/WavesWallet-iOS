//
//  KeyboardControl.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 06.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//
import UIKit

final class KeyboardControl: UIView, NibLoadable {
    
    struct Model {
        let title: String
    }
    
            
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
//        layer.cornerRadius = Constants.cornerRadius
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//        topBackgroundView.layer.cornerRadius = Constants.cornerRadius
//        topBackgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
    }
}
