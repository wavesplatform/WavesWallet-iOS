//
//  MobileKeeperCoordinator.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 26.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift
import DomainLayer
import WavesSDK

protocol MobileKeeperCoordinatorDelegate: AnyObject {
    
    func mobileKeeperCoordinatorError(_ error: MobileKeeperUseCaseError)
}

final class MobileKeeperCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    
    weak var parent: Coordinator?
    
    private var navigationRouter: NavigationRouter
    
    private var windowRouter: WindowRouter
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let request: DomainLayer.DTO.MobileKeeper.Request
    
    private let mobileKeeperRepository: MobileKeeperRepositoryProtocol = UseCasesFactory.instance.repositories.mobileKeeperRepository
    
    private var snackError: String? = nil
    
    weak var delegate: MobileKeeperCoordinatorDelegate?
    
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
    
    private func closeWindow(completed: (() -> Void)? = nil) {
        self.windowRouter.dissmissWindow(animated: .crossDissolve) {
            completed?()
            self.removeFromParentCoordinator()
        }
    }
    
    private func rejectAndClose(request: DomainLayer.DTO.MobileKeeper.Request) {
        
        mobileKeeperRepository
            .rejectRequest(request)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (result) in
                
                self?.closeWindow(completed: {
                    if result == false {
                        self?.delegate?.mobileKeeperCoordinatorError(MobileKeeperUseCaseError.dAppDontOpen)
                    }
                })
            }, onError: { [weak self] (error) in
                
                self?.closeWindow(completed: {
                    if let error = error as? MobileKeeperUseCaseError {
                        self?.delegate?.mobileKeeperCoordinatorError(error)
                    }
                })
            })
            .disposed(by: disposeBag)
        
    }
    
    private func errorAndClose(request: DomainLayer.DTO.MobileKeeper.Request, error: DomainLayer.DTO.MobileKeeper.Error) {
        
        mobileKeeperRepository
            .errorRequest(request, error: error)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (result) in
                
                if result == false {
                    self?.delegate?.mobileKeeperCoordinatorError(MobileKeeperUseCaseError.dAppDontOpen)
                }
                self?.closeWindow()
            }, onError: { [weak self] (error) in
                    
                self?.closeWindow(completed: {
                    if let error = error as? MobileKeeperUseCaseError {
                        self?.delegate?.mobileKeeperCoordinatorError(error)
                    }
                })
            })
            .disposed(by: disposeBag)        
    }

}

// MARK: ApplicationCoordinatorProtocol

extension MobileKeeperCoordinator: ApplicationCoordinatorProtocol {
    func showEnterDisplay() {
        rejectAndClose(request: request)
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
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (wallet) in
                guard let self = self else { return }
                
                let vc = ConfirmRequestModuleBuilder(output: self)
                    .build(input: .init(request: self.request, signedWallet: wallet ))
                
                self.navigationRouter.pushViewController(vc)
            })
            .disposed(by: disposeBag)
    }
    
    func userDidTapBackButton() {
        rejectAndClose(request: request)
    }
}

extension MobileKeeperCoordinator: ConfirmRequestModuleOutput {
    
    func confirmRequestDidTapClose(_ prepareRequest: DomainLayer.DTO.MobileKeeper.PrepareRequest) {
        errorAndClose(request: prepareRequest.request, error: .invalidRequest)
    }
    
    func confirmRequestDidTapReject(_ complitingRequest: ConfirmRequest.DTO.ComplitingRequest) {
        rejectAndClose(request: complitingRequest.prepareRequest.request)
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
                            .observeOn(MainScheduler.asyncInstance)
                            .subscribe(onNext: { [weak self] (result) in
                                
                                self?.closeWindow(completed: {
                                    if result == false {
                                        self?.delegate?.mobileKeeperCoordinatorError(MobileKeeperUseCaseError.dAppDontOpen)
                                    }
                                })
                                
                            }, onError: { [weak self] (error) in
                                
                                self?.closeWindow(completed: {
                                    if let error = error as? MobileKeeperUseCaseError {
                                        self?.delegate?.mobileKeeperCoordinatorError(error)
                                    }
                                })
                            })
                            .disposed(by: self.disposeBag)
                    }
                    
                    self.navigationRouter.pushViewController(vc)
                case .sign:
                    
                    self.mobileKeeperRepository
                        .approveRequest(completed)
                        .observeOn(MainScheduler.asyncInstance)
                        .subscribe(onNext: { [weak self] (result) in
                            
                            self?.closeWindow(completed: {
                                if result == false {
                                    self?.delegate?.mobileKeeperCoordinatorError(MobileKeeperUseCaseError.dAppDontOpen)
                                }
                            })
                            
                        }, onError: { [weak self] (error) in
                            
                            self?.closeWindow(completed: {
                                if let error = error as? MobileKeeperUseCaseError {
                                    self?.handlerError(with: error)
                                }
                            })
                        })
                        .disposed(by: self.disposeBag)
                    
                }
            }, onError: { [weak self] (error) in
                
                if let error = error as? MobileKeeperUseCaseError {
                    self?.handlerError(with: error)
                    
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func handlerError(with error: MobileKeeperUseCaseError) {
        
        switch error {
        case .dAppDontOpen:
            showErrorView(with: error)
            
        case .dataIncorrect:
            errorAndClose(request: request, error: .invalidRequest)
            
        case .transactionDontSupport:
            errorAndClose(request: request, error: .transactionDontSupport)
            
        default:
            break
        }
        
        showErrorView(with: error)
    }
    
    private func showErrorView(with error: MobileKeeperUseCaseError) {
        
        if let snackError = snackError {
            UIApplication.shared.windows.last?.rootViewController?.hideSnack(key: snackError)
        }
        
        switch error {
        case .dAppDontOpen:
            snackError = showErrorSnack("Application don't open")
            
        case .dataIncorrect:
            snackError = showErrorSnack("Request incorect")
        
        case .transactionDontSupport:
            snackError = showErrorSnack("Transaction don't support")
        default:
            snackError = UIApplication.shared.windows.last?.rootViewController?.showErrorNotFoundSnackWithoutAction()
        }
    }
    
    private func showErrorSnack(_ message: (String)) -> String? {
        return UIApplication.shared.windows.last?.rootViewController?.showErrorSnackWithoutAction(title: message)
    }
}
