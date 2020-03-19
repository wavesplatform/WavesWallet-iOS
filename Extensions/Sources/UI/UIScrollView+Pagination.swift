//
//  UIScrollView+ Pagination.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/23/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit

public extension UIScrollView {
    
    var currentPage: Int {
        return Int(contentOffset.x / bounds.size.width)
    }
    
    var maxPages: Int {
        return Int(contentSize.width / bounds.size.width)
    }
    
    func nextPage(animated: Bool = true) {
        setContentOffset(CGPoint(x: contentOffset.x + frame.width, y: contentOffset.y), animated: animated)
    }
}

