//
//  NavigationRouter.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 15/01/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

final class NavigationRouter: NSObject {

    private var completions: [UIViewController : () -> Void] = .init()

    public var navigationController: UINavigationController

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
        self.navigationController.delegate = self
    }

    func present(_ viewController: UIViewController, animated: Bool = true) {
        navigationController.present(viewController, animated: animated, completion: nil)
    }

    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        navigationController.dismiss(animated: animated, completion: completion)
    }

    func pushViewController(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {

        if let completion = completion {
            completions[viewController] = completion
        }

        navigationController.pushViewController(viewController, animated: animated)
    }

    func popAllAndSetRootViewController(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {

        if let completion = completion {
            completions[viewController] = completion
        }

        navigationController.setViewControllers([viewController], animated: animated)
    }

    func popViewController(animated: Bool = true)  {
        if let controller = navigationController.popViewController(animated: animated) {
            runCompletion(for: controller)
        }
    }

    public func popToRootViewController(animated: Bool) {
        if let controllers = navigationController.popToRootViewController(animated: animated) {
            controllers.forEach { runCompletion(for: $0) }
        }
    }

    fileprivate func runCompletion(for controller: UIViewController) {
        guard let completion = completions[controller] else { return }
        completion()
        completions.removeValue(forKey: controller)
    }
}

// MARK: UINavigationControllerDelegate
extension NavigationRouter: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {

        guard let poppedViewController = navigationController.transitionCoordinator?.viewController(forKey: .from),
            !navigationController.viewControllers.contains(poppedViewController) else {
                return
        }

        runCompletion(for: poppedViewController)
    }
}
