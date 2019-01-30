//
//  PopoverViewController.swift
//  Popover
//
//  Created by mefilt on 28/01/2019.
//  Copyright © 2019 Mefilt. All rights reserved.
//

import Foundation
import UIKit

protocol PopoverPresentationAnimatorContext {
    func contectHeight(for size:  CGSize) -> CGFloat
}

protocol PopoverPresentationAnimatorScrollContext {
    func contectHeight(for size:  CGSize) -> CGFloat
//    func contectHeight(for size:  CGSize) -> CGFloat
}

protocol PopoverPresentationAnimatorScrollViewContext: PopoverPresentationAnimatorContext {
    var scrollView: UIScrollView { get }
}
