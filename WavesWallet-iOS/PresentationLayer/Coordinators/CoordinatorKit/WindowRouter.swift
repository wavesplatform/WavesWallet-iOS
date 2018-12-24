//
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 27/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

public protocol WindowRouterType: class {
	var window: UIWindow { get }
	init(window: UIWindow)
	func setRootModule(_ module: Presentable)
}

final class WindowRouter: NSObject {

    enum AnimateKind {
        case crossDissolve
    }
	
	public let window: UIWindow
	
	public init(window: UIWindow) {
		self.window = window
		super.init()
	}
	
    public func setRootViewController(_ viewController: UIViewController, animated: AnimateKind? = nil) {

        if let animated = animated {
            switch animated {
            case .crossDissolve:
                if let view = window.rootViewController?.view {
                    UIView.transition(from: view, to: viewController.view, duration: 0.24, options: [.transitionCrossDissolve], completion: { _ in
                        self.window.rootViewController = viewController
                    })
                } else {
                    self.window.rootViewController = viewController
                }
            }
        } else {
            self.window.rootViewController = viewController
        }
        window.makeKeyAndVisible()
	}

    public func dissmissWindow(animated: AnimateKind? = nil, completed: (() -> Void)? = nil) {

        UIView.animate(withDuration: 0.24, delay: 0, options: [.curveEaseInOut], animations: {
            var newFrame = self.window.frame
            newFrame.origin.y = newFrame.height
            self.window.frame = newFrame
            self.window.alpha = 0
        }) { _ in
            completed?()
        }

    }
}

final class SlideMenuRouter: NSObject {

    public let slideMenu: SlideMenu

    public init(slideMenu: SlideMenu) {
        self.slideMenu = slideMenu
        super.init()
    }

    public func setLeftMenuViewController(_ viewController: UIViewController) {
        slideMenu.leftMenuViewController = viewController
    }

    public func setContentViewController(_ viewController: UIViewController) {
        slideMenu.contentViewController = viewController
    }
}

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
