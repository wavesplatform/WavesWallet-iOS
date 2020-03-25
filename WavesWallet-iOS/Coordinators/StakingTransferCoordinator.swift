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
        let vc = StakingTransferModuleBuilder(output: self).build(input: .init(assetId: assetId,
                                                                             kind: kind))
        modalRouter.pushViewController(vc)
        router.present(modalRouter, animated: true, completion: nil)
    }
    
    private func removeModalFromCoordinator() {
        self.hasNeedRemoveCoordinatorAfterDissmiss = false
        router.dismiss(animated: true, completion: nil)
        modalRouter.popAllViewController()
    }
    
    private func showTransactionCompleted(transaction: DomainLayer.DTO.SmartTransaction) {
        
                
        let vc = TransactionCompletedBuilder().build(input: transaction)
        vc.modalPresentationStyle = .overFullScreen
        router.present(vc, animated: true, completion: nil)
    }
}

extension StakingTransferCoordinator: StakingTransferModuleOutput {
    
    func stakingTransferOpenURL(_ url: URL) {
        removeModalFromCoordinator()
    }
    
    func stakingTransferDidSendDeposit(transaction: DomainLayer.DTO.SmartTransaction) {
        removeModalFromCoordinator()
                
        showTransactionCompleted(transaction: transaction)
    }
    
    func stakingTransferDidSendWithdraw(transaction: DomainLayer.DTO.SmartTransaction) {
        
        removeModalFromCoordinator()
        showTransactionCompleted(transaction: transaction)
    }
    
    func stakingTransferDidSendCard(url: URL) {        
        removeModalFromCoordinator()
    }
}
