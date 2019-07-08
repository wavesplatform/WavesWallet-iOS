//
//  LanguageCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Mac on 03/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class EnterLanguageCoordinator: Coordinator {
 
    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?
    
    private let popup: PopupViewController = PopupViewController()
    
    func start() {

        let enterLanguage = StoryboardScene.Language.languageViewController.instantiate()
        enterLanguage.delegate = self
        popup.present(contentViewController: enterLanguage)
        popup.onDismiss = { [weak self] in
            guard let self = self else { return }
            self.removeFromParentCoordinator()
        }
    }
}

// MARK: LanguageViewControllerDelegate

extension EnterLanguageCoordinator: LanguageViewControllerDelegate {
    
    func languageViewChangedLanguage() {
        removeFromParentCoordinator()
        popup.dismissPopup()
    }
}
