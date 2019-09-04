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
    
    private let mobileKeeperRepository: MobileKeeperRepositoryProtocol = UseCasesFactory.instance.repositories.mobileKeeperRepository
    
    private var snackError: String? = nil
    
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
    
    private func closeWindow() {
        removeFromParentCoordinator()
        self.windowRouter.dissmissWindow()
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
        
        mobileKeeperRepository.rejectRequest(request)
        closeWindow()        
    }
}

extension MobileKeeperCoordinator: ConfirmRequestModuleOutput {
    
    func confirmRequestDidTapReject(_ complitingRequest: ConfirmRequest.DTO.ComplitingRequest) {
        
        self.mobileKeeperRepository.rejectRequest(complitingRequest.prepareRequest.request)
        closeWindow()
    }
    
    func confirmRequestDidTapApprove(_ complitingRequest: ConfirmRequest.DTO.ComplitingRequest) {
        
        
        let action = complitingRequest.prepareRequest.request.action
        
        switch action {
        case .send:
            let vc = StoryboardScene.MobileKeeper.confirmRequestLoadingViewController.instantiate()
            navigationRouter.pushViewController(vc)
        case .sign:
            break
        }
        
        mobileKeeperRepository
            .completeRequest(complitingRequest.prepareRequest)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (completed) in
                
                guard let self = self else { return }
                
                switch completed.request.action {
                case .send:
                    let vc = StoryboardScene.MobileKeeper.confirmRequestCompleteViewController.instantiate()
                    
                    vc.completedRequest = completed
                    vc.complitingRequest = complitingRequest
                    vc.okButtonDidTap = { [weak self] () -> Void in
                        
                        guard let self = self else { return }
                        
                        self.mobileKeeperRepository
                            .approveRequest(completed)
                            .subscribe(onNext: { [weak self] (result) in
                                
                                if result == false {
                                    self?.showErrorView(with: MobileKeeperUseCaseError.dAppDontOpen)
                                }
                                
                            }, onError: { [weak self] (error) in
                                if let error = error as? MobileKeeperUseCaseError {
                                    self?.showErrorView(with: error)
                                }
                            })
                            .disposed(by: self.disposeBag)
                        self.closeWindow()
                    }
                    
                    self.navigationRouter.pushViewController(vc)
                case .sign:
                    
                    //TODO: Error
                    self.mobileKeeperRepository
                        .approveRequest(completed)
                        .subscribe(onNext: { [weak self] (result) in
                            
                            if result == false {
                                self?.showErrorView(with: MobileKeeperUseCaseError.dAppDontOpen)
                            }
                            
                        }, onError: { [weak self] (error) in
                            if let error = error as? MobileKeeperUseCaseError {
                                self?.showErrorView(with: error)
                            }
                        })
                        .disposed(by: self.disposeBag)
                    
                    self.closeWindow()
                }
            }, onError: { [weak self] (error) in
                
                if let error = error as? MobileKeeperUseCaseError {
                    self?.showErrorView(with: error)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func showErrorView(with error: MobileKeeperUseCaseError) {
        
        if let snackError = snackError {
            self.navigationRouter.viewController.hideSnack(key: snackError)
        }
        
        switch error {
        case .dAppDontOpen:
            snackError = showErrorSnack("    Dont open")
            
        case .dataIncorrect:
            snackError = showErrorSnack("Request incorect")
        
        case .transactionDontSupport:
            snackError = showErrorSnack("Transaction dont support")
        default:
            snackError = self.navigationRouter.viewController.showErrorNotFoundSnack()
        }
    }
    
    private func showErrorSnack(_ message: (String)) -> String {
        return self.navigationRouter.viewController.showErrorSnack(title: message)
    }
}

fileprivate extension ConfirmRequest.DTO.ComplitingRequest {
    
//    var completingRequest: DomainLayer.DTO.MobileKeeper.CompletingRequest.init(
}
