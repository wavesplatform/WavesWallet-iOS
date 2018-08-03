//
//  HistoryCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Mac on 01/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class HistoryCoordinator {
    
    private lazy var historyViewController: NewHistoryViewController = {
        let vc = StoryboardScene.History.newHistoryViewController.instantiate()
//        vc.isMenuButton = true
        
//        let presenter = HistoryPresenter()
//        vc.presenter = presenter
//        presenter.moduleOutput = self
        
        return vc
    }()
    
    private var navigationController: UINavigationController!
    
    func start(navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigationController.pushViewController(historyViewController, animated: false)
    }
    
}
