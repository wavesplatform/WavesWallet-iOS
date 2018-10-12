//
//  LanguageCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Mac on 03/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class EnterLanguageViewCoordinator: Coordinator {
 
    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?
 
    private let parentController: UIViewController
    private let popup = PopupViewController()
    
    init(parentController: UIViewController) {
        self.parentController = parentController
    }
    
    func start() {

        let enterLanguage = StoryboardScene.Language.languageViewController.instantiate()
        enterLanguage.delegate = self
        popup.present(contentViewController: enterLanguage)
    }
}

// MARK: LanguageViewControllerDelegate

extension EnterLanguageViewCoordinator: LanguageViewControllerDelegate {

    func languageViewChangedLanguage() {
        removeFromParentCoordinator()
        popup.dismissPopup()
    }
}
