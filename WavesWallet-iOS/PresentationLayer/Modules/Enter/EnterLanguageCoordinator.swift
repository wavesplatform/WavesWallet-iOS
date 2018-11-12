//
//  LanguageCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Mac on 03/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol EnterLanguageCoordinatorDelegate: class {
    
}

final class EnterLanguageCoordinator: Coordinator {
 
    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?
    
    var popup: PopupViewController!
 
    private let parentController: UIViewController
    
    weak var delegate: EnterLanguageCoordinatorDelegate?
    
    init(parentController: UIViewController) {
        self.parentController = parentController
    }
    
    func start() {
        popup = PopupViewController()
        let enterLanguage = StoryboardScene.Language.languageViewController.instantiate()
        enterLanguage.delegate = self
        
        popup.present(contentViewController: enterLanguage)
    }
    
}

// MARK: LanguageViewControllerDelegate

extension EnterLanguageCoordinator: LanguageViewControllerDelegate {
    
    func languageViewChangedLanguage() {
        removeFromParentCoordinator()
        popup.dismissPopup()
    }
}
