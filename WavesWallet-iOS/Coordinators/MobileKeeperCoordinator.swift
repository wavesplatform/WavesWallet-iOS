//
//  MobileKeeperCoordinator.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 26.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import DomainLayer
import WavesSDK

final class MobileKeeperCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    
    weak var parent: Coordinator?
    
    private var navigationRouter: NavigationRouter
    
    private var windowRouter: WindowRouter
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    private lazy var popoverViewControllerTransitioning = ModalViewControllerTransitioning { [weak self] in
        guard let self = self else { return }
    }
    private let request: DomainLayer.DTO.MobileKeeper.Request
    
    init(windowRouter: WindowRouter, request: DomainLayer.DTO.MobileKeeper.Request) {
        
        self.request = request
        let window = UIWindow()
        window.windowLevel = UIWindow.Level.init(rawValue: UIWindow.Level.normal.rawValue + 1.0)
        self.windowRouter = WindowRouter.windowFactory(window: window)
        self.navigationRouter = NavigationRouter(navigationController: CustomNavigationController())
    }
    
    func start() {
        
        windowRouter.setRootViewController(self.navigationRouter.navigationController)
        let coordinator = ChooseAccountCoordinator(navigationRouter: navigationRouter, applicationCoordinator: self)
        coordinator.delegate = self
        addChildCoordinatorAndStart(childCoordinator: coordinator)
    }
}

// MARK: ApplicationCoordinatorProtocol

extension MobileKeeperCoordinator: ApplicationCoordinatorProtocol {
    func showEnterDisplay() {
        
    }
}

// MARK: ChooseAccountCoordinatorDelegate

extension MobileKeeperCoordinator: ChooseAccountCoordinatorDelegate {
    
    func userChooseCompleted(wallet: DomainLayer.DTO.Wallet) {
        
        UseCasesFactory
            .instance
            .authorization
            .authorizedWallet()
            .take(1)
            .subscribe(onNext: { [weak self] (wallet) in
                guard let self = self else { return }
                
                let vc = ConfirmRequestModuleBuilder(output: self)
                    .build(input: .init(request: self.request, signedWallet: wallet ))
                
                self.navigationRouter.pushViewController(vc)
            })
            .disposed(by: disposeBag)
    }
    
    func userDidTapBackButton() {
        removeFromParentCoordinator()
        self.windowRouter.dissmissWindow()
        //TODO: Send Reject
    }
}

extension MobileKeeperCoordinator: ConfirmRequestModuleOutput {
    
    func confirmRequestDidTapReject(_ complitingRequest: ConfirmRequest.DTO.ComplitingRequest) {
        
        //TODO: Reject
    }
    
    func confirmRequestDidTapApprove(_ complitingRequest: ConfirmRequest.DTO.ComplitingRequest) {
//
//        switch request.data.action {
//        case .send:
//
//            let vc = StoryboardScene.MobileKeeper.confirmRequestCompleteViewController.instantiate()
//            navigationRouter.pushViewController(vc)
//
////            let vc = StoryboardScene.MobileKeeper.confirmRequestLoadingViewController.instantiate()
////            navigationRouter.pushViewController(vc)
//
//        case .sign:
//
//            let vc = StoryboardScene.MobileKeeper.confirmRequestCompleteViewController.instantiate()
//            navigationRouter.pushViewController(vc)
//
//            //TODO: Send
//            break
//        }
//
    }
}
