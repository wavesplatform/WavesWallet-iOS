//
//  UIScrollView+ContentInset.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 29/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

extension UIScrollView {

    var adjustedContentInsetAdapter: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return adjustedContentInset
        } else {
            return UIEdgeInsets.zero
        }
    }
}
