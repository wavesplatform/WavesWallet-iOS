//
//  HighlightedButton.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/23/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let cornerRadius: CGFloat = 3
}

class HighlightedButton: UIButton {
       
    @IBInspectable var highlightedBackground: UIColor?
    private var defaultBackgroundColor: UIColor?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    override var backgroundColor: UIColor? {
        didSet {
            if backgroundColor != highlightedBackground {
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
    
    func initialize() {
        layer.cornerRadius = Constants.cornerRadius
    }
    
    func setupBackgroundColor() {
        backgroundColor = isHighlighted ? highlightedBackground : defaultBackgroundColor
    }
}
