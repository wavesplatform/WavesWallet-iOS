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

    func contectHeight(for size:  CGSize) -> CGFloat

    func appearingContectHeight(for size:  CGSize) -> CGFloat

    func disappearingContectHeight(for size:  CGSize) -> CGFloat
}

protocol ModalPresentationAnimatorSimpleContext: ModalPresentationAnimatorContext {}

extension ModalPresentationAnimatorSimpleContext {
    func appearingContectHeight(for size:  CGSize) -> CGFloat {

        let contectHeight = self.contectHeight(for: size)
        return size.height - contectHeight
    }

    func disappearingContectHeight(for size:  CGSize) -> CGFloat {
        return size.height
    }
}

