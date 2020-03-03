//
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 27/10/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit
import DomainLayer

private enum Constants {
    static let animationDuration: TimeInterval = 0.24
}

class WindowRouter: NSObject {

    enum AnimateKind {
        case crossDissolve
    }
	
	public let window: UIWindow
	
	public init(window: UIWindow) {
		self.window = window
		super.init()
	}
	
    public func setRootViewController(_ router: Router, animated: AnimateKind? = nil) {
        setRootViewController(router.viewController, animated: animated)
    }
        
    public func setRootViewController(_ viewController: UIViewController,
                                      animated: AnimateKind? = nil,
                                      completion: (()  -> Void)? = nil) {

        if let animated = animated {
            switch animated {
            case .crossDissolve:
                if let view = window.rootViewController?.view {
                    
                   self.window.rootViewController = viewController
                    UIView.transition(from: view, to: viewController.view, duration: Constants.animationDuration, options: [.transitionCrossDissolve], completion: { animated in
                        self.windowDidAppear()
                        completion?()
                    })
                } else {
                    self.window.rootViewController = viewController
                    self.window.makeKeyAndVisible()
                    self.windowDidAppear()
                    completion?()
                }
            }
        } else {
            self.window.rootViewController = viewController
            self.window.makeKeyAndVisible()
            self.windowDidAppear()
            completion?()
        }
	}
    
    public func dissmissWindow(animated: AnimateKind? = nil, completed: (() -> Void)? = nil) {

        UIView.animate(withDuration: Constants.animationDuration, delay: 0, options: [.curveEaseInOut], animations: {
            var newFrame = self.window.frame
            newFrame.origin.y = newFrame.height
            self.window.frame = newFrame
            self.window.alpha = 0
        }) { _ in
            completed?()
        }

    }
    
    func windowDidAppear() {}
}


extension WindowRouter: Router {
        
    var viewController: UIViewController {
        return window.rootViewController ?? UIViewController()
    }

    func present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        self.viewController.present(viewController, animated: animated, completion: completion)
    }

    func dismiss(animated: Bool, completion: (() -> Void)?) {
        self.viewController.dismiss(animated: true, completion: completion)
    }
}
