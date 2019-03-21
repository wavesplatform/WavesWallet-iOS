//
//  PopoverViewControllerTransitioning.swift
//  Popover
//
//  Created by mefilt on 29/01/2019.
//  Copyright © 2019 Mefilt. All rights reserved.
//

import Foundation
import UIKit

final class ModalViewControllerTransitioning: NSObject {

    private let dismiss: ModalPresentationController.DismissCompleted?

    init(dismiss: ModalPresentationController.DismissCompleted?) {
        self.dismiss = dismiss
    }
}

extension ModalViewControllerTransitioning: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalPresentationAnimator(isPresentation: true)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalPresentationAnimator(isPresentation: false)
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController?  {
        return ModalPresentationController(presentedViewController: presented, presenting: presenting, dismiss: { [weak self] in
            self?.dismiss?()
        })
    }
}
