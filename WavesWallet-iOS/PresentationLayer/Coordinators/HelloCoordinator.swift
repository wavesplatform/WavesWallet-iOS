//
//  HelloCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 12.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

protocol HelloCoordinatorDelegate: AnyObject {
    func userFinishedGreet()
    func userChangedLanguage(_ language: Language)
}

final class HelloCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?

    private var windowRouter: WindowRouter
    private var navigationRouter: NavigationRouter

    weak var delegate: HelloCoordinatorDelegate?

    init(windowRouter: WindowRouter) {
        self.windowRouter = windowRouter
        self.navigationRouter = NavigationRouter(navigationController: CustomNavigationController())
    }

    func start() {

        let vc = StoryboardScene.Hello.helloLanguagesViewController.instantiate()
        vc.output = self
//        viewController = vc
//        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: HelloLanguagesModuleOutput
extension HelloCoordinator: HelloLanguagesModuleOutput {

    func languageDidSelect(language: Language) {
        delegate?.userChangedLanguage(language)
    }

    func userFinishedChangeLanguage() {
        let vc = StoryboardScene.Hello.infoPagesViewController.instantiate()
        vc.output = self
//        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: InfoPagesViewControllerDelegate
extension HelloCoordinator: InfoPagesViewModuleOutput {
    func userFinishedReadPages() {
//        navigationController?.popViewController(animated: true)
        self.delegate?.userFinishedGreet()
        self.removeFromParentCoordinator()
    }
}

