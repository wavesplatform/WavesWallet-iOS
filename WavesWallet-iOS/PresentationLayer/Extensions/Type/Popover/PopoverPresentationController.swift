//
//  PopoverPresentationController.swift
//  Popover
//
//  Created by mefilt on 29/01/2019.
//  Copyright © 2019 Mefilt. All rights reserved.
//

import Foundation
import UIKit

final class PopoverPresentationController: UIPresentationController {

    typealias DismissCompleted = (() -> Void)

    private let dismiss: DismissCompleted?

    private let shadowView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.24)
        return view
    }()

    init(presentedViewController: UIViewController,
         presenting presentingViewController: UIViewController?,
         dismiss: DismissCompleted? = nil)
    {
        self.dismiss = dismiss
        super.init(presentedViewController: presentedViewController,
                   presenting: presentingViewController)
    }

    override func presentationTransitionWillBegin() {

        addShadowView()
        addGestureRecognizers()
        shadowView.alpha = 0
    
        if let containerView = containerView {
            presentedViewController.view.bounds.size = containerView.bounds.size
        }

        let animations = {
            self.shadowView.alpha = 1
        }

        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                animations()
            })
        } else {
            animations()
        }
    }

    override func dismissalTransitionWillBegin() {

        let animations = {
            self.shadowView.alpha = 0
        }

        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                animations()
            })
        } else {
            animations()
        }
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            dismiss?()
        }
    }
}

// MARK: - Private

extension PopoverPresentationController {

    @objc private func close() {
        presentedViewController.dismiss(animated: true)
    }

    private func addShadowView() {
        
        guard let containerView = containerView else {
            return
        }

        containerView.insertSubview(shadowView, at: 0)

        NSLayoutConstraint.activate([
            shadowView.topAnchor.constraint(equalTo: containerView.topAnchor),
            shadowView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            shadowView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            shadowView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
            ]
        )
    }

    private func addGestureRecognizers() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        shadowView.addGestureRecognizer(tapRecognizer)

        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(close))
        swipeRecognizer.direction = .down
        shadowView.addGestureRecognizer(swipeRecognizer)
    }
}
