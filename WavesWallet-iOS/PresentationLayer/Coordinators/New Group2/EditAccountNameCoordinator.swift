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
    private let wallet: DomainLayer.DTO.Wallet
    
    init(navigationController: UINavigationController, wallet: DomainLayer.DTO.Wallet) {
        self.navigationController = navigationController
        self.wallet = wallet
    }
    
    func start() {
        let vc = EditAccountNameModuleBuilder(output: self).build(input: .init(wallet: wallet))
        navigationController.pushViewController(vc, animated: true)
    }
    
}

extension EditAccountNameCoordinator: EditAccountNameModuleOutput {}

protocol EditAccountNameModuleInput {
    var wallet: DomainLayer.DTO.Wallet { get }
}

protocol EditAccountNameModuleOutput {}

