//
//  NavigationRouter.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 15/01/2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import UIKit

class NavigationRouter: NSObject {

    private var completions: [UIViewController : () -> Void] = .init()

    public var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
        self.navigationController.delegate = self
    }

    func pushViewController(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {

        if let completion = completion {
            completions[viewController] = completion
        }

        navigationController.pushViewController(viewController, animated: animated)
    }

    func popAllAndSetRootViewController(_ viewController: UIViewController,
                                        animated: Bool = true,
                                        completion: (() -> Void)? = nil) {

        if let completion = completion {
            completions[viewController] = completion
        }

        navigationController.setViewControllers([viewController], animated: animated)
    }

    func popViewController(animated: Bool = true) {
        if let controller = navigationController.popViewController(animated: animated) {
            runCompletion(for: controller)
        }
    }

    func popViewController(animated: Bool = true, completed: (() -> Void)? = nil) {
        if let controller = navigationController.popViewController(animated: animated) {
            runCompletion(for: controller)
            completed?()
        }
    }

    func popToRootViewController(animated: Bool = true) {
        if let controllers = navigationController.popToRootViewController(animated: animated) {
            controllers.forEach { runCompletion(for: $0) }
        }
    }

    func popToViewController(_ viewController: UIViewController, animated: Bool = true) {
        _ = navigationController.popToViewController(viewController, animated: true)
    }

    fileprivate func runCompletion(for controller: UIViewController) {
        guard let completion = completions[controller] else { return }
        completion()
        completions.removeValue(forKey: controller)
    }
}

// MARK: UINavigationControllerDelegate
extension NavigationRouter: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController, animated: Bool) {

        guard let poppedViewController = navigationController.transitionCoordinator?.viewController(forKey: .from),
            !navigationController.viewControllers.contains(poppedViewController) else {
                return
        }

        runCompletion(for: poppedViewController)
    }
}

extension NavigationRouter: Router {

    var viewController: UIViewController { navigationController }

    func present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        
        if #available(iOS 13, *) {
            if viewController.modalPresentationStyle == .pageSheet && !(viewController is UIAlertController) {
                viewController.modalPresentationStyle = .fullScreen
            }
        }
        navigationController.topViewController?.present(viewController, animated: animated, completion: completion)
    }

    func dismiss(animated: Bool, completion: (() -> Void)?) {
        navigationController.topViewController?.dismiss(animated: animated, completion: completion)
    }
}
