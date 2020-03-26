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
    
    private func showTransactionCompleted(amount: DomainLayer.DTO.Balance,
                                          transaction: DomainLayer.DTO.SmartTransaction,
                                          kind: TransactionCompletedVC.Model.Kind) {
        
                
        let vc = TransactionCompletedBuilder().build(input: .init(kind: kind,
                                                                  balance: amount))
        
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
}

// MARK: StakingTransferModuleOutput

extension StakingTransferCoordinator: StakingTransferModuleOutput {
    
    func stakingTransferOpenURL(_ url: URL) {
        removeModalFromCoordinator()
    }
    
    func stakingTransferDidSendDeposit(transaction: DomainLayer.DTO.SmartTransaction,
                                       amount: DomainLayer.DTO.Balance) {
        removeModalFromCoordinator()
                
        showTransactionCompleted(amount: amount,
                                 transaction: transaction,
                                 kind:  .deposit)
    }
    
    func stakingTransferDidSendWithdraw(transaction: DomainLayer.DTO.SmartTransaction,
                                        amount: DomainLayer.DTO.Balance) {
        
        removeModalFromCoordinator()
        showTransactionCompleted(amount: amount,
                                 transaction: transaction,
                                 kind:  .withdraw)
    }
    
    func stakingTransferDidSendCard(url: URL) {        
        removeModalFromCoordinator()
    }
}

// MARK: TransactionCardCoordinatorDelegate

extension StakingTransferCoordinator: TransactionCardCoordinatorDelegate {
    
    func transactionCardCoordinatorClosed() {
        removeFromParentCoordinator()
    }
}
