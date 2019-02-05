//
//  ModalPresentationAnimator
//  Popover
//
//  Created by mefilt on 29/01/2019.
//  Copyright © 2019 Mefilt. All rights reserved.
//

import Foundation
import UIKit

private enum Constants {
    static let animationDuration: TimeInterval = 0.38
}

final class ModalPresentationAnimator: NSObject {

    let isPresentation: Bool

    init(isPresentation: Bool) {
        self.isPresentation = isPresentation
        super.init()
    }
}

// MARK: - UIViewControllerAnimatedTransitioning

extension ModalPresentationAnimator: UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Constants.animationDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        let key = isPresentation ? UITransitionContextViewControllerKey.to : UITransitionContextViewControllerKey.from
        let parentKey = isPresentation ? UITransitionContextViewControllerKey.from : UITransitionContextViewControllerKey.to

        guard let parentController = transitionContext.viewController(forKey: parentKey) else { return }
        guard let controller = transitionContext.viewController(forKey: key) else { return }

        if isPresentation {
            transitionContext.containerView.addSubview(controller.view)
        }

        let parentFrame = transitionContext.finalFrame(for: parentController)

        let maxHeight = parentFrame.inset(by: UIEdgeInsets(top: 0,
                                                            left: 0,
                                                            bottom: 0,
                                                            right: 0)).height
        let width = parentFrame.size.width
        var height = maxHeight

        if let context = controller as? ModalPresentationAnimatorContext {
            height = context.contentHeight(for: CGSize(width: width,
                                                       height: maxHeight))
        }

        let maxSize = CGSize(width: width, height: maxHeight)

        let initialFrame: CGRect =  calculateFrame(isPresentation: !isPresentation,
                                                    maxSize: maxSize,
                                                    height: height,
                                                    controller: controller)


        let finalFrame: CGRect = calculateFrame(isPresentation: isPresentation,
                                                maxSize: maxSize,
                                                height: height,
                                                controller: controller)

        let animationDuration = transitionDuration(using: transitionContext)
        controller.view.frame = initialFrame

        UIView.animate(withDuration: animationDuration, animations: {
            controller.view.frame = finalFrame
        }, completion: { finished in
            transitionContext.completeTransition(finished)
        })
    }

    private func calculateFrame(isPresentation: Bool, maxSize: CGSize, height: CGFloat, controller: UIViewController) -> CGRect {

        var frame: CGRect!

        let maxHeight = maxSize.height
        let width = maxSize.width

        if let context = controller as? ModalPresentationAnimatorContext {

            let appY = context.appearingContentHeight(for: maxSize)
            let dissY = context.disappearingContentHeight(for: maxSize)

            if isPresentation {
                frame = CGRect(x: 0,
                               y: appY,
                               width: width,
                               height: height)
            } else {
                frame = CGRect(x: 0,
                               y: dissY,
                               width: width,
                               height: height)
            }

        } else {

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
        }



        return frame
    }
}
