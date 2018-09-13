//
//  HelloCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 12.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

final class HelloCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    var parent: Coordinator?

    private var window: UIWindow
    private var navigationController: UINavigationController!

    init(_ window: UIWindow) {
        self.window = window
    }

    func start() {
        let vc = StoryboardScene.Hello.helloLanguagesViewController.instantiate()
        navigationController = UINavigationController(rootViewController: vc)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}

// MARK: HelloLanguagesViewControllerDelegate
extension HelloCoordinator: HelloLanguagesViewControllerDelegate {

    func languageDidSelect(code: String) {
        //change language
        let vc = StoryboardScene.Hello.infoPagesViewController.instantiate()
        vc.delegate = self
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: InfoPagesViewControllerDelegate
extension HelloCoordinator: InfoPagesViewControllerDelegate {
    func userFinishedReadPages() {
        //        let controller = StoryboardManager.EnterStoryboard().instantiateViewController(withIdentifier: "EnterStartViewController")
        //        navigationController?.pushViewControllerAndSetLast(controller)
    }
}
