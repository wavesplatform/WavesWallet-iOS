//
//  HighlightedButton.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/23/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class HighlightedButton: UIButton {
       
    @IBInspectable var highlightedBackground: UIColor?
    private var defaultBackgroundColor: UIColor?
    
    override var backgroundColor: UIColor? {
        didSet {
            if defaultBackgroundColor == nil {
                defaultBackgroundColor = backgroundColor
            }
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            setupBackgroundColor()
        }
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupBackgroundColor()
    }
}

private extension HighlightedButton {
    func setupBackgroundColor() {
        backgroundColor = isHighlighted ? highlightedBackground : defaultBackgroundColor
    }
}
