//
//  WalletCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 24.07.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import RxSwift
import UIKit
import WavesSDKExtensions

private enum Constants {
    static let popoverHeight: CGFloat = 378
}

final class InvestmentCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    weak var parent: Coordinator?

    private lazy var walletViewContoller: InvestmentViewController = {
        InvestmentModuleBuilder(output: self).build()
    }()

    private var navigationRouter: NavigationRouter

    private weak var myAddressVC: UIViewController?

    private var currentPopup: PopupViewController?

    private let disposeBag: DisposeBag = DisposeBag()
    private let authorization: AuthorizationUseCaseProtocol = UseCasesFactory.instance.authorization
    private let walletsRepository: WalletsRepositoryProtocol = UseCasesFactory.instance.repositories.walletsRepositoryLocal

    private var hasSendedNewUserWithoutBackupStorageTrack: Bool = false

    init(navigationRouter: NavigationRouter) {
        self.navigationRouter = navigationRouter
    }

    func start() {
        setupLifeCycleTost()
        navigationRouter.pushViewController(walletViewContoller, animated: true, completion: nil)
    }

    private func setupLifeCycleTost() {
        walletViewContoller.rx
            .viewDidAppear
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.showLegalOrBackupIfNeeded()
            })
            .disposed(by: disposeBag)

        walletViewContoller.rx
            .viewDidDisappear
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }

                self.childCoordinators
                    .first(where: { (coordinator) -> Bool in
                        coordinator is BackupTostCoordinator
                    })?
                    .removeFromParentCoordinator()
            })
            .disposed(by: disposeBag)
    }

    private func showBackupTost() {
        if !hasSendedNewUserWithoutBackupStorageTrack {
            hasSendedNewUserWithoutBackupStorageTrack = true
            NewUserWithoutBackupStorageTrack.sendEvent()
        }

        let coordinator = BackupTostCoordinator(navigationRouter: navigationRouter)
        addChildCoordinatorAndStart(childCoordinator: coordinator)
    }

    private func showNews() {
        let coordinator = AppNewsCoordinator()
        addChildCoordinatorAndStart(childCoordinator: coordinator)
    }

    private func showPushAlertSettings() {
        let coordinator = PushNotificationsCoordinator()
        addChildCoordinatorAndStart(childCoordinator: coordinator)
    }

    private func showNewsAndBackupTost() {
        showBackupTost()
        showNews()
        showPushAlertSettings()
    }

    private func showLegalOrBackupIfNeeded() {
        authorization
            .authorizedWallet()
            .take(1)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.showNewsAndBackupTost()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: WalletModuleOutput

extension InvestmentCoordinator: InvestmentModuleOutput {
    func showAccountHistory() {
        let historyCoordinator = HistoryCoordinator(navigationRouter: navigationRouter, historyType: .all)
        addChildCoordinatorAndStart(childCoordinator: historyCoordinator)
    }

    func showPayoutsHistory() {
        let payoutsBuilder = PayoutsHistoryBuilder()
        let payoutsHistoryVC = payoutsBuilder.build()

        navigationRouter.pushViewController(payoutsHistoryVC)

        UseCasesFactory
            .instance
            .analyticManager
            .trackEvent(.staking(.mainPayoutsHistoryTap))
    }

    func openTw(sharedText: String) {
        let urlString = UIGlobalConstants.URL.twSharing + sharedText.urlEscaped
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }

        UseCasesFactory
            .instance
            .analyticManager
            .trackEvent(.staking(.mainShareTap(.twitter)))
    }

    func openVk(sharedText: String) {
        let urlString = UIGlobalConstants.URL.vkSharing + sharedText.urlEscaped
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }

        UseCasesFactory
            .instance
            .analyticManager
            .trackEvent(.staking(.mainShareTap(.vk)))
    }

    func openFb(sharedText: String) {
        let urlString = UIGlobalConstants.URL.fbSharing + sharedText.urlEscaped
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }

        UseCasesFactory
            .instance
            .analyticManager
            .trackEvent(.staking(.mainShareTap(.facebok)))
    }

    func openTrade(neutrinoAsset: Asset) {
        let coordinator = TradeCoordinator(navigationRouter: navigationRouter,
                                           selectedAsset: neutrinoAsset)
        addChildCoordinator(childCoordinator: coordinator)
        coordinator.start()

        UseCasesFactory
            .instance
            .analyticManager
            .trackEvent(.staking(.mainTradeTap))
    }

    func openBuy(neutrinoAsset: Asset) {
        let buyCryptoBuilder: BuyCryptoBuildable = BuyCryptoBuilder()
        let buyCryptoVC = buyCryptoBuilder.build(with: self, selectedAsset: neutrinoAsset)
        navigationRouter.pushViewController(buyCryptoVC)
        
//        let coordinator = StakingTransferCoordinator(router: navigationRouter, kind: .card)
//        coordinator.delegate = self
//        addChildCoordinator(childCoordinator: coordinator)
//        coordinator.start()

        UseCasesFactory
            .instance
            .analyticManager
            .trackEvent(.staking(.mainBuyTap))
    }

    func openDeposit(neutrinoAsset _: Asset) {
        let coordinator = StakingTransferCoordinator(router: navigationRouter, kind: .deposit)
        coordinator.delegate = self
        addChildCoordinator(childCoordinator: coordinator)
        coordinator.start()

        UseCasesFactory
            .instance
            .analyticManager
            .trackEvent(.staking(.mainDepositTap))
    }

    func openWithdraw(neutrinoAsset _: Asset) {
        let coordinator = StakingTransferCoordinator(router: navigationRouter, kind: .withdraw)
        coordinator.delegate = self
        addChildCoordinator(childCoordinator: coordinator)
        coordinator.start()

        UseCasesFactory
            .instance
            .analyticManager
            .trackEvent(.staking(.mainWithdrawTap))
    }

    func openStakingFaq(fromLanding: Bool) {
        if fromLanding {
            UseCasesFactory
                .instance
                .analyticManager
                .trackEvent(.staking(.landingFAQTap))
        } else {
            UseCasesFactory
                .instance
                .analyticManager
                .trackEvent(.staking(.mainFAQTap))
        }

        BrowserViewController.openURL(URL(string: UIGlobalConstants.URL.stakingFaq)!)
    }

    func openAppStore() {
        UseCasesFactory
            .instance
            .analyticManager
            .trackEvent(.walletHome(.updateBanner))

        RateApp.show()
    }

    func showHistoryForLeasing() {
        let historyCoordinator = HistoryCoordinator(navigationRouter: navigationRouter, historyType: .leasing)
        addChildCoordinatorAndStart(childCoordinator: historyCoordinator)
    }

    func showStartLease(availableMoney: Money) {
        let controller = StartLeasingModuleBuilder(output: self).build(input: availableMoney)
        navigationRouter.pushViewController(controller)

        UseCasesFactory.instance.analyticManager.trackEvent(.walletLeasing(.leasingStartTap))
    }

    func showLeasingTransaction(transactions: [SmartTransaction], index: Int) {
        let coordinator = TransactionCardCoordinator(transaction: transactions[index], router: navigationRouter)
        coordinator.delegate = self

        addChildCoordinatorAndStart(childCoordinator: coordinator)
    }
}

extension InvestmentCoordinator: BuyCryptoListener {
    func openUrl(_ url: URL, delegate: BrowserViewControllerDelegate?) {
        BrowserViewController.openURL(url, toViewController: navigationRouter.navigationController, delegate: delegate)
    }
}

// MARK: - TransactionCardCoordinatorDelegate

extension InvestmentCoordinator: TransactionCardCoordinatorDelegate {
    func transactionCardCoordinatorCanceledLeasing() {
        walletViewContoller.viewWillAppear(false)
    }
}

// MARK: - StartLeasingModuleOutput

extension InvestmentCoordinator: StartLeasingModuleOutput {
    func startLeasingDidSuccess(transaction _: SmartTransaction, kind _: StartLeasingTypes.Kind) {}
}

// MARK: StakingTransferCoordinatorDelegate

extension InvestmentCoordinator: StakingTransferCoordinatorDelegate {
    func stakingTransferSendDepositCompled(balance: DomainLayer.DTO.Balance) {
        walletViewContoller.completedDepositBalance(balance: balance)
    }

    func stakingTransferSendWithdrawCompled(balance: DomainLayer.DTO.Balance) {
        walletViewContoller.completedWithdrawBalance(balance: balance)
    }

    func stakingTransferSendCardCompled() {
        walletViewContoller.refreshData()
    }
}
