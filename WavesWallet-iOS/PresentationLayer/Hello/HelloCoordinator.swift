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
    var parent: Coordinator?

    weak var delegate: HelloCoordinatorDelegate?

    private var viewController: UIViewController
    private var navigationController: UINavigationController!

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func start() {
        let vc = StoryboardScene.Hello.helloLanguagesViewController.instantiate()
        vc.output = self
        navigationController = UINavigationController(rootViewController: vc)
        viewController.present(navigationController, animated: false, completion: nil)
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
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: InfoPagesViewControllerDelegate
extension HelloCoordinator: InfoPagesViewModuleOutput {
    func userFinishedReadPages() {
        viewController.dismiss(animated: true) {
            self.delegate?.userFinishedGreet()
            self.removeFromParentCoordinator()
        }
    }
}
