//
//  AmountTapButton.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/14/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let backgroundSize: CGFloat = 28
}

final class DexCreateOrderAmountButton: UIButton {

    private let background = UIView(frame: CGRect(x: 0, y: 0, width: Constants.backgroundSize, height: Constants.backgroundSize))
   
    override func layoutSubviews() {
        super.layoutSubviews()
        background.center = center
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        background.isUserInteractionEnabled = false
        background.isHidden = true
        background.backgroundColor = .basic100
        background.layer.cornerRadius = background.frame.size.width / 2
        background.clipsToBounds = true
        superview?.addSubview(background)
        superview?.bringSubviewToFront(self)
    }
    
    override var isHighlighted: Bool {
        didSet {
            background.isHidden = !isHighlighted
        }
    }
}
