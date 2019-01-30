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

protocol PopoverPresentationAnimatorScrollViewContext: PopoverPresentationAnimatorContext {
    var scrollView: UIScrollView { get }
}

//protocol PopoverPresentationAnimatorScrollViewContext: PopoverPresentationAnimatorContext {
//
//    var scrollView: UIScrollView { get}
//
//    func visibleScrollViewHeight(for size: CGSize) -> CGFloat
//}
//
//extension PopoverPresentationAnimatorScrollViewContext {
//
//    func appearContentHeight(for size:  CGSize) -> CGFloat {
//        return visibleScrollViewHeight(for: size) + scrollView.contentOffset.y + scrollView.contentInset.top
//    }
//
//    func disappearContentHeight(for size:  CGSize) -> CGFloat {
//
//        if scrollView.contentOffset.y < 0 {
//             return visibleScrollViewHeight(for: size) + scrollView.contentInset.top
//        } else {
//             return visibleScrollViewHeight(for: size) + scrollView.contentOffset.y + scrollView.contentInset.top
//        }
//    }
//}
