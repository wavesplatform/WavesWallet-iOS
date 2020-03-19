//
//  NSMutableAttributedString+URL.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 23.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit

// MARK: NSMutableAttributedStrin

extension NSMutableAttributedString {

    static func urlAttributted() -> [NSAttributedString.Key: Any] {
        
        return [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13),
                NSAttributedString.Key.foregroundColor: UIColor.submit400,
                NSAttributedString.Key.underlineStyle: NSNumber(value: false)]
    }
}
