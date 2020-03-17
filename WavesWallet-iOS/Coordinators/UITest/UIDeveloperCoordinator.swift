//
//  UIDeveloperCoordinator.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 28.07.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import UIKit
import Extensions

final class UIDeveloperCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    weak var parent: Coordinator?
    
    private var windowRouter: WindowRouter
    private var navigationRouter: NavigationRouter
    
    weak var delegate: HelloCoordinatorDelegate?
    
    private lazy var popoverViewControllerTransitioning = ModalViewControllerTransitioning { [weak self] in
        guard let self = self else { return }
    }
    
    init(windowRouter: WindowRouter) {
        self.windowRouter = windowRouter
        self.navigationRouter = NavigationRouter(navigationController: CustomNavigationController())
    }
    
    func start() {
        
                
        let data = TooltipTypes.DTO.Data.init(title: "Help", elements: [.init(title: "Bitcoin Address Options", description: "SegWit Addresses beginning with \"bc1\" reduce transaction fees, but may not work everywhere. Regular Addresses beginning with \"1\" work everywhere. Both are safe to use."),
        .init(title: "Bitcoin Address Options", description: "SegWit Addresses beginning with \"bc1\" reduce transaction fees, but may not work everywhere. Regular Addresses beginning with \"1\" work everywhere. Both are safe to use.")])
        
        let vc = TooltipModuleBuilder(output: self)
            .build(input: .init(data: data))
        
        navigationRouter.viewController.modalPresentationStyle = .custom
        navigationRouter.viewController.transitioningDelegate = popoverViewControllerTransitioning
        
        navigationRouter.pushViewController(vc)
        
        let vcRoot = UIViewController()
        vcRoot.view = UIView()
        vcRoot.view.bounds = UIScreen.main.bounds
        
        self.windowRouter.setRootViewController(vcRoot)
        
        vcRoot.present(navigationRouter.navigationController, animated: true, completion: nil)
    }
    
    
}

extension UIDeveloperCoordinator: TooltipViewControllerModulOutput {
    func tooltipDidTapClose() {
        
    }
}
    
extension UIDeveloperCoordinator {
    func applicationDidEnterBackground() {}

    func applicationDidBecomeActive() {}
    func openURL(link: DeepLink) {}
}
