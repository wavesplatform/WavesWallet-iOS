//
//  LanguageCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Mac on 03/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class LanguageCoordinator: Coordinator {
 
    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?
 
    private let parentController: UIViewController
    
    init(parentController: UIViewController) {
        self.parentController = parentController
    }
    
    func start() {
        let enterLanguage = StoryboardScene.Enter.enterLanguageViewController.instantiate()
        parentController.present(enterLanguage, animated: true, completion: nil)
    }
    
}
