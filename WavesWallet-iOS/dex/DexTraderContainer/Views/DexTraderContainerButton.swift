//
//  DexTraderContainerButton.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/23/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

fileprivate enum Constants {
    static let titleFontSize: CGFloat = 10
    static let subTitleFontSize: CGFloat = 13
    static let lineSpacing: CGFloat = 3
    static let cornerRadius: CGFloat = 3
}

final class DexTraderContainerButton: HighlightedButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = Constants.cornerRadius
    }
    
    func setup(title: String, subTitle: String) {
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = Constants.lineSpacing
        paragraph.alignment = .center
        
        let attributes =  [NSAttributedStringKey.font : UIFont.systemFont(ofSize: Constants.subTitleFontSize, weight: .semibold),
                           NSAttributedStringKey.foregroundColor : UIColor.white,
                           NSAttributedStringKey.paragraphStyle : paragraph]
        
        let text = title + "\n" + subTitle
        let attrString = NSMutableAttributedString(string: text, attributes: attributes)
        attrString.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: Constants.titleFontSize), range: (text as NSString).range(of: title))
        
        titleLabel?.numberOfLines = 0
        titleLabel?.attributedText = attrString
        setAttributedTitle(attrString, for: .normal)
    }
}
