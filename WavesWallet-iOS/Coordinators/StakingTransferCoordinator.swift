//
//  StakingTransferCoordinator.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 19.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import Extensions
import DomainLayer

final class StakingTransferCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []

    weak var parent: Coordinator?

    private var router: Router
    
    private let kind: StakingTransfer.DTO.Kind
    
    private let assetId: String
    
    private var hasNeedRemoveCoordinatorAfterDissmiss: Bool = true
    
    private lazy var modalRouter: ModalRouter = ModalRouter(navigationController: CustomNavigationController()) { [weak self] in
        
        if self?.hasNeedRemoveCoordinatorAfterDissmiss == true {
            self?.removeCoordinators()
        }
    }
            
    init(router: Router, kind: StakingTransfer.DTO.Kind, assetId: String = "DG2xFkPdDwKUoBkzGAhQtLpSGzfXLiCYPEzeKH2Ad24p") {
        self.router = router
        self.kind = kind
        self.assetId = assetId
    }

    func start() {
        let vc = StakingTransferModuleBuilder(output: self)
            .build(input: .init(assetId: assetId,
                                kind: kind))
        modalRouter.pushViewController(vc)
        router.present(modalRouter, animated: true, completion: nil)
    }
    
    private func removeModalFromCoordinator() {
        self.hasNeedRemoveCoordinatorAfterDissmiss = false
        router.dismiss(animated: true, completion: nil)
        modalRouter.popAllViewController()
    }
    
    
    private func showTransactionCompleted(transaction: DomainLayer.DTO.SmartTransaction,
                                          kind: StakingTransactionCompletedVC.Model.Kind) {
                        
        let vc = StakingTransactionCompletedBuilder().build(input: .init(kind: kind))
        
        vc.didTapSuccessButton = { [weak self] in
            vc.dismiss(animated: true, completion: nil)
            self?.removeFromParentCoordinator()
        }
        
        vc.didTapDetailButton = { [weak self] in
            vc.dismiss(animated: true, completion: nil)
            guard let self = self else { return }
            
            let cordinator = TransactionCardCoordinator(kind: .transaction(transaction),
                                                        router: self.router)
            cordinator.delegate = self
            
            self.addChildCoordinatorAndStart(childCoordinator: cordinator)
        }
        
        
        vc.modalPresentationStyle = .overFullScreen
        router.present(vc, animated: true, completion: nil)
    }
    
    private func showCardCompleted() {
                
        let vc = StakingTransactionCompletedBuilder().build(input: .init(kind: .card))

        vc.didTapSuccessButton = { [weak self] in
            vc.dismiss(animated: true, completion: nil)
            self?.removeFromParentCoordinator()
        }

        vc.didSelectLinkWith = { url -> Void in
            BrowserViewController.openURL(url,
                                          toViewController: self.router.viewController)
        }
        
        vc.modalPresentationStyle = .overFullScreen
        router.present(vc, animated: true, completion: nil)
    }
}

// MARK: StakingTransferModuleOutput

extension StakingTransferCoordinator: StakingTransferModuleOutput {
    
    func stakingTransferOpenURL(_ url: URL) {
        
        BrowserViewController.openURL(url,
                                      toViewController: router.viewController)
    }
    
    func stakingTransferDidSendDeposit(transaction: DomainLayer.DTO.SmartTransaction,
                                       amount: DomainLayer.DTO.Balance) {
        removeModalFromCoordinator()
                
        showTransactionCompleted(transaction: transaction,
                                 kind:  .deposit(balance: amount))
    }
    
    func stakingTransferDidSendWithdraw(transaction: DomainLayer.DTO.SmartTransaction,
                                        amount: DomainLayer.DTO.Balance) {
        
        removeModalFromCoordinator()
        showTransactionCompleted(transaction: transaction,
                                 kind:  .withdraw(balance: amount))
    }
    
    func stakingTransferDidSendCard(url: URL) {        
        
        BrowserViewController.openURL(url,
                                      toViewController: modalRouter.viewController  ,
                                        delegate: self)
    }
}

// MARK: TransactionCardCoordinatorDelegate

extension StakingTransferCoordinator: TransactionCardCoordinatorDelegate {
    
    func transactionCardCoordinatorClosed() {
        removeFromParentCoordinator()
    }
}

// MARK: BrowserViewControllerDelegate

extension StakingTransferCoordinator: BrowserViewControllerDelegate {

    func browserViewDissmiss() {}
    
    func browserViewRedirect(aurl: URL) {
        let url = URL.init(string: DomainLayerConstants.URL.fiatDepositSuccess)!
        
        if url.path.contains(DomainLayerConstants.URL.fiatDepositSuccess) {
            removeModalFromCoordinator()
            showCardCompleted()
        } else if url.path.contains(DomainLayerConstants.URL.fiatDepositFail)  {
            router.viewController.showErrorNotFoundSnackWithoutAction()
        }
    }
}
