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
	
	public unowned let window: UIWindow
	
	public init(window: UIWindow) {
		self.window = window
		super.init()
	}
	
    public func setRootViewController(_ viewController: UIViewController) {
		window.rootViewController = viewController
	}
}
