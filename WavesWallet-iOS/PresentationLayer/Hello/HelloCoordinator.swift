//
//  HelloCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 12.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

final class HelloCoordinator {

    func start(window: UIWindow) {

        let vc = StoryboardScene.Hello.helloLanguagesViewController.instantiate()
        window.rootViewController = vc
        window.makeKeyAndVisible()
    }
}

