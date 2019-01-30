//
//  PopoverViewControllerTransitioning.swift
//  Popover
//
//  Created by mefilt on 29/01/2019.
//  Copyright © 2019 Mefilt. All rights reserved.
//

import Foundation
import UIKit

final class PopoverViewControllerTransitioning: NSObject {

    private var animator = PopoverPresentationAnimator(isPresentation: false)

    private let dismiss: PopoverPresentationController.DismissCompleted?

    init(dismiss: PopoverPresentationController.DismissCompleted?) {
        self.dismiss = dismiss
    }
}

extension PopoverViewControllerTransitioning: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PopoverPresentationAnimator(isPresentation: true)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PopoverPresentationAnimator(isPresentation: false)
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController?  {
        return PopoverPresentationController(presentedViewController: presented, presenting: presenting, dismiss: { [weak self] in
            self?.dismiss?()
        })
    }
}
