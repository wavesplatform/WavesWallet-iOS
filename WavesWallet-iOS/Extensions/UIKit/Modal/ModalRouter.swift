//
//  ModalRouter.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 19.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit

class ModalRouter: NavigationRouter {
            
    private lazy var modalTransitioning = ModalViewControllerTransitioning { [weak self] in
        guard let self = self else { return }
        self.dismiss?()
    }
            
    private let dismiss: ModalPresentationController.DismissCompleted?

    init(navigationController: CustomNavigationController,
         dismiss: ModalPresentationController.DismissCompleted?) {
        self.dismiss = dismiss
        super.init(navigationController: navigationController)
        navigationController.modalPresentationStyle = .custom
        navigationController.transitioningDelegate = modalTransitioning
    }
}
