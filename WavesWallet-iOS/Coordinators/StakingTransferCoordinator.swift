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
    
    private lazy var modalRouter: ModalRouter = ModalRouter(navigationController: CustomNavigationController()) { [weak self] in
        self?.removeCoordinators()
    }
    
    init(router: Router){
        self.router = router
        

    }

    func start() {
        let vc = StoryboardScene.StakingTransfer.stakingTransferViewController.instantiate()
        modalRouter.pushViewController(vc)
        router.present(modalRouter, animated: true, completion: nil)
    }
    
    deinit {
         print("deinit")
     }
}
