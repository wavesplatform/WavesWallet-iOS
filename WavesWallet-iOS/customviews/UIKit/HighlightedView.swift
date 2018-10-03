//
//  HighlightedView.swift
//  WavesWallet-iOS
//
//  Created by Mac on 04/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class HighlightedView: UIControl {
    
    @IBInspectable var highlightedBackground: UIColor = UIColor.basic50
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

private extension HighlightedView {
    
    func initialize() {
        
    }
    
    func setupBackgroundColor() {
        backgroundColor = isHighlighted ? highlightedBackground : defaultBackgroundColor
    }
    
}
