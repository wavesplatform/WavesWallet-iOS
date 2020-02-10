//
//  CenteringContentButton.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 20.08.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit

final class CenteringContentButton: UIButton {

    fileprivate enum Constants {
        static let titleTopPadding: CGFloat = 8
    }

    @IBInspectable var titleTopPadding: CGFloat = Constants.titleTopPadding
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.titleLabel?.numberOfLines = 1
        self.titleLabel?.lineBreakMode = .byTruncatingTail
        self.titleLabel?.textAlignment = .center
        self.layoutIfNeeded()
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {

        let iconSize = super.imageRect(forContentRect: contentRect).size
        let titleSize = super.titleRect(forContentRect: contentRect).size
                
        var height = iconSize.height
        height += titleSize.height + titleTopPadding


        return CGRect(x: (contentRect.size.width - iconSize.width) * 0.5,
                      y: ((contentRect.height - height) * 0.5),
                      width: iconSize.width,
                      height: iconSize.height)
    }
    
    override func contentRect(forBounds bounds: CGRect) -> CGRect {
        return super.contentRect(forBounds: bounds)
    }
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {

        var titleSize = super.titleRect(forContentRect: contentRect).size
        titleSize.width = contentRect.width
        
        let iconSize = super.imageRect(forContentRect: contentRect).size
                
        var height = titleSize.height

        if iconSize.height > 0 {
            height += iconSize.height + titleTopPadding
        }

        return CGRect(x: (contentRect.size.width - titleSize.width) * 0.5,
                      y: contentRect.height - ((contentRect.height - height) * 0.5) - titleSize.height,
                      width: titleSize.width,
                      height: titleSize.height)
    }
}
