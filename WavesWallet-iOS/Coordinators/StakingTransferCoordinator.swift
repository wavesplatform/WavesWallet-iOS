//
//  StakingTransferCoordinator.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 19.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit

final class StakingTransferCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []

    weak var parent: Coordinator?

    private var router: Router
    
    private lazy var modelRouter: ModalRouter = ModalRouter(navigationController: CustomNavigationController()) { [weak self] in
        self?.removeCoordinators()
    }

    private let stakingTransferViewController: StakingTransferViewController = StakingTransferViewController()
    
    init(router: Router){
        self.router = router
        
        let vc = StoryboardScene.StakingTransfer.stakingTransferViewController.instantiate()
        
//        let vc = ModalTableModuleBuilder().build(input: stakingTransferViewController)
        modelRouter.pushViewController(vc)
    }

    func start() {
        router.present(modelRouter, animated: true, completion: nil)
    }
}
