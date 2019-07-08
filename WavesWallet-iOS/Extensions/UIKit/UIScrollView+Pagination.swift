//
//  UIScrollView+ Pagination.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/23/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    var currentPage: Int {
        return Int(contentOffset.x / bounds.size.width)
    }
}

