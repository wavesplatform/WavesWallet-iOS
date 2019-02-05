//
//  PopoverViewController.swift
//  Popover
//
//  Created by mefilt on 28/01/2019.
//  Copyright © 2019 Mefilt. All rights reserved.
//

import Foundation
import UIKit

protocol ModalPresentationAnimatorContext {

    func contentHeight(for size:  CGSize) -> CGFloat

    func appearingContentHeight(for size:  CGSize) -> CGFloat

    func disappearingContentHeight(for size:  CGSize) -> CGFloat
}

protocol ModalPresentationAnimatorSimpleContext: ModalPresentationAnimatorContext {}

extension ModalPresentationAnimatorSimpleContext {
    func appearingContentHeight(for size:  CGSize) -> CGFloat {

        let contentHeight = self.contentHeight(for: size)
        return size.height - contentHeight
    }

    func disappearingContentHeight(for size:  CGSize) -> CGFloat {
        return size.height
    }
}

