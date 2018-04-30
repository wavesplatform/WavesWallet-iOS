//
//  StringExtension.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 03/05/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import Foundation

extension String {
    
    func removeCharacters(from forbiddenChars: CharacterSet) -> String {
        let passed = self.unicodeScalars.filter { !forbiddenChars.contains($0) }
        return String(String.UnicodeScalarView(passed))
    }
    
    func removeCharacters(from: String) -> String {
        return removeCharacters(from: CharacterSet(charactersIn: from))
    }
    
    func maxHeight(font: UIFont, forWidth: CGFloat) -> CGFloat {
        let text = self as NSString
        return ceil(text.boundingRect(with: CGSize(width:forWidth, height:CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName : font], context: nil).size.height)
    }
}
