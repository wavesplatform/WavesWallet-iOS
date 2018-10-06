//
//  WavesButton.swift
//  WavesWallet-iOS
//
//  Created by Mac on 19/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class WavesButton: UIButton {
    
    enum ButtonState {
        case normal
        case selected
    }
    
    private(set) var wavesState: ButtonState = .normal
    
    var normalTitle: String?
    var selectedTitle: String?
    
    var normalImage: UIImage?
    var selectedImage: UIImage?
    
    var normalTitleColor: UIColor?
    var selectedTitleColor: UIColor?
    
    func setState(_ state: ButtonState) {
        wavesState = state
        
        if state == .selected {
            setTitleColor(selectedTitleColor, for: .normal)
            setTitle(selectedTitle, for: .normal)
            setImage(selectedImage, for: .normal)
        } else {
            setTitleColor(normalTitleColor, for: .normal)
            setTitle(normalTitle, for: .normal)
            setImage(normalImage, for: .normal)
        }
    }
    
}
