//
//  NSAttributedString+Styles.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 19.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

extension NSAttributedString {
    class func styleForBalance(text: String, font: UIFont) -> NSAttributedString {
        let range = (text as NSString).range(of: ".")
        let attrString = NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: font.pointSize, weight: .semibold)])

        if range.location != NSNotFound {
            let length = text.count - range.location
            attrString.addAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: font.pointSize, weight: .regular)], range: NSRange(location: range.location, length: length))
        }
        return attrString
    }
    
    class func styleForMyAssetName(assetName: String, isMyAsset: Bool) -> NSAttributedString {
        
        var fullName = assetName
        let myAssetString = " / \(Localizable.Waves.Wallet.Label.myAssets)"
        
        if isMyAsset {
            fullName.append(myAssetString)
        }
        
        let attrString = NSMutableAttributedString(string: fullName)
        attrString.setAttributes([NSAttributedStringKey.foregroundColor : UIColor.info500,
                                NSAttributedStringKey.font : UIFont.systemFont(ofSize: 10)],
                               range:  (fullName as NSString).range(of: myAssetString))
        return attrString
    }
}
