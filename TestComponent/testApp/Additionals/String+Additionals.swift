//
//  String+Additionals.swift
//  testApp
//
//  Created by Pavel Gubin on 5/13/19.
//  Copyright © 2019 Pavel Gubin. All rights reserved.
//

import UIKit

extension String {
    func maxWidth(font: UIFont) -> CGFloat {
        let text = self as NSString
        return ceil(text.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil).size.width)
    }
    func maxHeight(font: UIFont, forWidth: CGFloat) -> CGFloat {
        let text = self as NSString
        return ceil(text.boundingRect(with: CGSize(width: forWidth, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil).size.height)
    }
}
