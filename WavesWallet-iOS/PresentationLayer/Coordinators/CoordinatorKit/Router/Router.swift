//
//  Router.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 18/01/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

protocol Router {

    var viewController: UIViewController { get }

    func present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?)

    func dismiss(animated: Bool, completion: (() -> Void)?)
}

extension Router {

    func present(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.viewController.present(viewController, animated: animated, completion: nil)
    }

    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        viewController.dismiss(animated: animated, completion: completion)
    }
}
