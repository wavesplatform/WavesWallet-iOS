//
//  PopverPresentationAnimator.swift
//  Popover
//
//  Created by mefilt on 29/01/2019.
//  Copyright © 2019 Mefilt. All rights reserved.
//

import Foundation
import UIKit

final class PopverPresentationAnimator: NSObject {

    let isPresentation: Bool

    private lazy var panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlerScrollPanGesture(recognizer:)))

    init(isPresentation: Bool) {
        self.isPresentation = isPresentation
        super.init()
    }
}

// MARK: - UIViewControllerAnimatedTransitioning

extension PopverPresentationAnimator: UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        let key = isPresentation ? UITransitionContextViewControllerKey.to : UITransitionContextViewControllerKey.from
        let parentKey = isPresentation ? UITransitionContextViewControllerKey.from : UITransitionContextViewControllerKey.to

        guard let parentController = transitionContext.viewController(forKey: parentKey) else { return }
        guard let controller = transitionContext.viewController(forKey: key) else { return }

        if isPresentation {
            transitionContext.containerView.addSubview(controller.view)
        }

        if let context = controller as? PopoverPresentationAnimatorScrollViewContext {
            let scrollView = context.scrollView
            panGesture.delegate = self
            scrollView.addGestureRecognizer(panGesture)
        }

        let parentFrame = transitionContext.finalFrame(for: parentController)

        let maxHeight = parentFrame.inset(by: UIEdgeInsets(top: 0,
                                                            left: 0,
                                                            bottom: 0,
                                                            right: 0)).height
        let width = parentFrame.size.width
        var height = maxHeight

        if let context = controller as? PopoverPresentationAnimatorContext {
            height = context.contectHeight(for: CGSize(width: width,
                                                       height: maxHeight))
        }

        let maxSize = CGSize(width: width, height: maxHeight)

        let initialFrame: CGRect =  calculateFrame(isPresentation: !isPresentation,
                                                     maxSize: maxSize,
                                                     height: height)


        let finalFrame: CGRect = calculateFrame(isPresentation: isPresentation,
                                                    maxSize: maxSize,
                                                    height: height)

        let animationDuration = transitionDuration(using: transitionContext)
        controller.view.frame = initialFrame

        UIView.animate(withDuration: animationDuration, animations: {
            controller.view.frame = finalFrame
        }, completion: { finished in
            transitionContext.completeTransition(finished)
        })
    }

    private func calculateFrame(isPresentation: Bool, maxSize: CGSize, height: CGFloat) -> CGRect {

        var frame: CGRect!

        let maxHeight = maxSize.height
        let width = maxSize.width

        if isPresentation {
            frame = CGRect(x: 0,
                           y: maxHeight - height,
                           width: width,
                           height: height)
        } else {
            frame = CGRect(x: 0,
                           y: maxHeight,
                           width: width,
                           height: height)
        }

        return frame
    }

    @objc private func handlerScrollPanGesture(recognizer: UIPanGestureRecognizer) {

    }
}

extension PopverPresentationAnimator: UIGestureRecognizerDelegate {


    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}
