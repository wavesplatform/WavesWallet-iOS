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

protocol StakingTransferCoordinatorDelegate: AnyObject {
    
    func stakingTransferSendDepositCompled(balance: DomainLayer.DTO.Balance)
    func stakingTransferSendWithdrawCompled(balance: DomainLayer.DTO.Balance)
    func stakingTransferSendCardCompled()
}

final class StakingTransferCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    
    weak var parent: Coordinator?
    
    private var router: Router
    
    private let kind: StakingTransfer.DTO.Kind
    
    private let assetId: String
    
    private var hasNeedRemoveCoordinatorAfterDissmiss: Bool = true
    
    private var adCashBrowserViewController: BrowserViewController?
    
    private var amountByBuyCard: DomainLayer.DTO.Balance?
    
    weak var delegate: StakingTransferCoordinatorDelegate?
    
    private lazy var modalRouter: ModalRouter = ModalRouter(navigationController: CustomNavigationController()) { [weak self] in
        
        if self?.hasNeedRemoveCoordinatorAfterDissmiss == true {
            self?.removeCoordinators()
        }
    }
    
    init(router: Router, kind: StakingTransfer.DTO.Kind, assetId: String) {
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
    
    
    private func showTransactionCompleted(transaction: SmartTransaction,
                                          kind: StakingTransactionCompletedVC.Model.Kind) {
        
        let vc = StakingTransactionCompletedBuilder().build(input: .init(kind: kind))
        
        vc.didTapSuccessButton = { [weak self] in
            
            switch kind {
            case .card: break
                
            case .deposit(let balance):
                
                let event: AnalyticManagerEventStaking = .depositSuccess(amount: balance.money.amount,
                                                                         assetTicker: balance.currency.displayText)
                UseCasesFactory
                    .instance
                    .analyticManager
                    .trackEvent(.staking(event))
                
                self?.delegate?.stakingTransferSendDepositCompled(balance: balance)
                
            case .withdraw( let balance):
                
                let event: AnalyticManagerEventStaking = .withdrawSuccess(amount: balance.money.amount,
                                                                          assetTicker: balance.currency.displayText)
                
                UseCasesFactory
                    .instance
                    .analyticManager
                    .trackEvent(.staking(event))
                
                self?.delegate?.stakingTransferSendWithdrawCompled(balance: balance)
            }
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
            
            let event: AnalyticManagerEventStaking = .cardSuccess(amount: amount.money.amount,
                                                                  assetTicker: amount.currency.displayText)
            
            UseCasesFactory
                .instance
                .analyticManager
                .trackEvent(.staking(event))
            
            self?.delegate?.stakingTransferSendCardCompled()
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
                                      toViewController: self.router.viewController)
    }
    
    func stakingTransferDidSendDeposit(transaction: SmartTransaction,
                                       amount: DomainLayer.DTO.Balance) {
        removeModalFromCoordinator(completion: { [weak self] in
            
            self?.showTransactionCompleted(transaction: transaction,
                                           kind:  .deposit(balance: amount))
        })
    }
    
    func stakingTransferDidSendWithdraw(transaction: SmartTransaction,
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
        
        
        self.adCashBrowserViewController = BrowserViewController.openURL(url,
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
    
    private func showErrorCashCancelled() {
        let title = Localizable.Waves.Staking.Refillerror.refillByAdvancedCashCancelled
        modalRouter.viewController.showErrorSnackWithoutAction(tille: title, duration: 3.24)
    }
    
    func browserViewDissmiss() {
        showErrorCashCancelled()
    }
    
    func browserViewRedirect(_: BrowserViewController, url: URL) {
        
        let link = url.absoluteStringByTrimmingQuery() ?? ""
        
        if link.contains(DomainLayerConstants.URL.fiatDepositSuccess) {
            
            removeModalFromCoordinator(completion: { [weak self] in
                guard let amount = self?.amountByBuyCard else { return }
                self?.showCardCompleted(amount: amount)
            })
            
        } else if link.contains(DomainLayerConstants.URL.fiatDepositFail)  {
            adCashBrowserViewController?.dismiss(animated: true, completion: { [weak self] in
                self?.showErrorCashCancelled()
            })
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
