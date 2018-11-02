//
//  EditAccountNameCoordinator.swift
//  WavesWallet-iOS
//
//  Created by Mac on 02/11/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class EditAccountNameCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = EditAccountNameModuleBuilder(output: self).build(input: .init())
        navigationController.pushViewController(vc, animated: true)
    }
    
}

extension EditAccountNameCoordinator: EditAccountNameModuleOutput {}

protocol EditAccountNameModuleInput {}
protocol EditAccountNameModuleOutput {}

