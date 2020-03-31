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
    
    private var amountByBuyCard: DomainLayer.DTO.Balance?
    
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
    
    private func removeModalFromCoordinator(completion: (() -> Void)? = nil) {
        self.hasNeedRemoveCoordinatorAfterDissmiss = false
        modalRouter.popAllViewController()
        router.dismiss(animated: true, completion: completion)
    }
    
    
    private func showTransactionCompleted(transaction: DomainLayer.DTO.SmartTransaction,
                                          kind: StakingTransactionCompletedVC.Model.Kind) {
        
        let vc = StakingTransactionCompletedBuilder().build(input: .init(kind: kind))
        
        vc.didTapSuccessButton = { [weak self] in
            vc.dismiss(animated: true, completion: nil)
            self?.removeFromParentCoordinator()
            
            switch kind {
            case .card: break
                        
            case .deposit(let balance):
                
                let event: AnalyticManagerEventStaking = .depositSuccess(amount: balance.money.amount,
                                                                         assetTicker: balance.currency.displayText)
                UseCasesFactory
                    .instance
                    .analyticManager
                    .trackEvent(.staking(event))
                
            case .withdraw( let balance):
                
                let event: AnalyticManagerEventStaking = .withdrawSuccess(amount: balance.money.amount,
                                                                          assetTicker: balance.currency.displayText)
                
                UseCasesFactory
                    .instance
                    .analyticManager
                    .trackEvent(.staking(event))
            }
            
        }
        
        vc.didTapDetailButton = { [weak self] in
            vc.dismiss(animated: true, completion: nil)
            guard let self = self else { return }
            
            let cordinator = TransactionCardCoordinator(kind: .transaction(transaction),
                                                        router: self.router)
            cordinator.delegate = self
            
            self.addChildCoordinatorAndStart(childCoordinator: cordinator)
            
            switch kind {
            case .card: break
                
            case .deposit:
                UseCasesFactory
                    .instance
                    .analyticManager
                    .trackEvent(.staking(.depositSuccessViewDetails))
                
            case .withdraw:
                UseCasesFactory
                    .instance
                    .analyticManager
                    .trackEvent(.staking(.withdrawSuccessViewDetails))
            }
        }
        
        vc.modalPresentationStyle = .overFullScreen
        router.present(vc, animated: true, completion: nil)
    }
    
    private func showCardCompleted(amount: DomainLayer.DTO.Balance) {
        
        let vc = StakingTransactionCompletedBuilder().build(input: .init(kind: .card))
        
        vc.didTapSuccessButton = { [weak self] in
            vc.dismiss(animated: true, completion: nil)
            self?.removeFromParentCoordinator()
            
            let event: AnalyticManagerEventStaking = .cardSuccess(amount: amount.money.amount,
                                                                  assetTicker: amount.currency.displayText)
            
            UseCasesFactory
                .instance
                .analyticManager
                .trackEvent(.staking(event))
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
                                      toViewController: self.router.viewController)
    }
    
    func stakingTransferDidSendDeposit(transaction: DomainLayer.DTO.SmartTransaction,
                                       amount: DomainLayer.DTO.Balance) {
        removeModalFromCoordinator(completion: { [weak self] in
            
            self?.showTransactionCompleted(transaction: transaction,
                                           kind:  .deposit(balance: amount))
        })
    }
    
    func stakingTransferDidSendWithdraw(transaction: DomainLayer.DTO.SmartTransaction,
                                        amount: DomainLayer.DTO.Balance) {
        
        removeModalFromCoordinator(completion: { [weak self] in
            self?.showTransactionCompleted(transaction: transaction,
                                           kind:  .withdraw(balance: amount))
        })
    }
    
    func stakingTransferDidSendCard(url: URL, amount: DomainLayer.DTO.Balance) {        
        
        self.amountByBuyCard = amount
        
        let event: AnalyticManagerEventStaking = .cardSendTap(amount: amount.money.amount,
                                                              assetTicker: amount.currency.displayText)
            
        UseCasesFactory
            .instance
            .analyticManager
            .trackEvent(.staking(event))
        
        
        BrowserViewController.openURL(url,
                                      toViewController: modalRouter.viewController,
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
    
    func browserViewRedirect(url: URL) {
        
        let link = url.absoluteStringByTrimmingQuery() ?? ""
        
        if link.contains(DomainLayerConstants.URL.fiatDepositSuccess) {
            
            removeModalFromCoordinator(completion: { [weak self] in
                guard let amount = self?.amountByBuyCard else { return }
                self?.showCardCompleted(amount: amount)
            })
            
        } else if link.contains(DomainLayerConstants.URL.fiatDepositFail)  {
            modalRouter.viewController.showErrorNotFoundSnackWithoutAction()
        }
    }
}

// TODO: Move
extension URL {
    func absoluteStringByTrimmingQuery() -> String? {
        if var urlcomponents = URLComponents(url: self, resolvingAgainstBaseURL: false) {
            urlcomponents.query = nil
            return urlcomponents.string
        }
        return nil
    }
}
