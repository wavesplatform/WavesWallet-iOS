//
//  PopupActionView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 2/15/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let animationDuration: TimeInterval = 0.3
    static let defaultBottomOffset: CGFloat = 24
    
    enum Shadow {
        static let offset = CGSize(width: 0, height: 4)
        static let opacity: Float = 0.2
        static let shadowRadius: Float = 4
    }
}


class PopupActionView: UIView {

    @IBOutlet private weak var viewBackground: UIView!
    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var bottomOffset: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewContainer.setupShadow(options: .init(offset: Constants.Shadow.offset,
                                                 color: .black,
                                                 opacity: Constants.Shadow.opacity,
                                                 shadowRadius: Constants.Shadow.shadowRadius,
                                                 shouldRasterize: true))
    }
    
    func setupInitialAnimationPoition() {

        viewBackground.alpha = 0
        bottomOffset.constant = initialViewPosition
        layoutIfNeeded()
        bottomOffset.constant = Constants.defaultBottomOffset
        UIView.animate(withDuration: Constants.animationDuration) {
            self.viewBackground.alpha = 1
            self.layoutIfNeeded()
        }
    }
    
    private var initialViewPosition: CGFloat {
        return -(viewContainer.frame.size.height + Constants.defaultBottomOffset)
    }
    
    func dismiss() {
        
        bottomOffset.constant = initialViewPosition
        
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.layoutIfNeeded()
            self.viewBackground.alpha = 0
        }) { (complete) in
            self.removeFromSuperview()
        }
    }
}
