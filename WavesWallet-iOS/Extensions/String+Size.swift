//
//  String+Size.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 24/05/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

public extension String {

    func maxHeight(font: UIFont, forWidth: CGFloat) -> CGFloat {
        let text = self as NSString
        let textSize = text.boundingRect(with: CGSize(width: forWidth, height: CGFloat.greatestFiniteMagnitude),
                                         context: nil)
        
        return ceil(textSize.height)
    }
    
    func maxHeightMultiline(font: UIFont, forWidth: CGFloat) -> CGFloat {
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byWordWrapping
        
        let rect = NSAttributedString(string: self, attributes: [.font: font,
                                                                 .paragraphStyle: style])
            .boundingRect(with: CGSize(width: forWidth,
                                       height: CGFloat.greatestFiniteMagnitude),
                          options: [.usesLineFragmentOrigin, .usesFontLeading],
                          context: nil)
        
        return ceil(rect.height)
    }
    
    func maxWidth(font: UIFont) -> CGFloat {
        let text = self as NSString
        let textSize = text.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude,
                                                      height: CGFloat.greatestFiniteMagnitude),
                                         context: nil)
        return ceil(textSize.width)
    }        
}

public extension NSAttributedString {
    
    func boundingRect(with size: CGSize) -> CGRect {
        boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
    }
}
