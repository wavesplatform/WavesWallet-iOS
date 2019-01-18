//
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 27/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let animationDuration: TimeInterval = 0.24
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
                    UIView.transition(from: view, to: viewController.view, duration: Constants.animationDuration, options: [.transitionCrossDissolve], completion: { _ in
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
