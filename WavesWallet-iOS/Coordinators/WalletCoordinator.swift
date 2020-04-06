//
//  WalletCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 24.07.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit
import RxSwift
import WavesSDKExtensions
import DomainLayer
import Extensions

private enum Constants {
    static let popoverHeight: CGFloat = 378
}

final class WalletCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []

    weak var parent: Coordinator?

    private lazy var walletViewContoller: WalletViewController = {
        return WalletModuleBuilder(output: self).build(input: self.isDisplayInvesting)
    }()

    private var navigationRouter: NavigationRouter

    private weak var myAddressVC: UIViewController?

    private var currentPopup: PopupViewController? = nil

    private let disposeBag: DisposeBag = DisposeBag()
    private let authorization: AuthorizationUseCaseProtocol = UseCasesFactory.instance.authorization
    private let walletsRepository: WalletsRepositoryProtocol = UseCasesFactory.instance.repositories.walletsRepositoryLocal
    
    private var hasSendedNewUserWithoutBackupStorageTrack: Bool = false
    private let isDisplayInvesting: Bool
    
    init(navigationRouter: NavigationRouter, isDisplayInvesting: Bool) {
        self.navigationRouter = navigationRouter
        self.isDisplayInvesting = isDisplayInvesting
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
                self.showLegalOrBackupIfNeed()
            })
            .disposed(by: disposeBag)

        walletViewContoller.rx
            .viewDidDisappear
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }

                self.childCoordinators
                    .first(where: { (coordinator) -> Bool in
                        return coordinator is BackupTostCoordinator
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

    private func showLegalOrBackupIfNeed() {

        self.authorization
            .authorizedWallet()
            .take(1)
            .subscribe(onNext: { [weak self] wallet in
                guard let self = self else { return }
                self.showNewsAndBackupTost()
            })
            .disposed(by: self.disposeBag)
    }
}

// MARK: WalletModuleOutput

extension WalletCoordinator: WalletModuleOutput {
    
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
    
    func showPayout(payout: PayoutTransactionVM) {
        print("payout tapped", payout)
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
    
    func openTrade(neutrinoAsset: DomainLayer.DTO.Asset) {
        
        let coordinator = TradeCoordinator(navigationRouter: self.navigationRouter,
                                           selectedAsset: neutrinoAsset)
        addChildCoordinator(childCoordinator: coordinator)
        coordinator.start()
        
        UseCasesFactory
        .instance
        .analyticManager
            .trackEvent(.staking(.mainTradeTap))
    }
    
    func openBuy(neutrinoAsset: DomainLayer.DTO.Asset) {
        let coordinator = StakingTransferCoordinator(router: self.navigationRouter, kind: .card)
        coordinator.delegate = self
        addChildCoordinator(childCoordinator: coordinator)
        coordinator.start()
        
        UseCasesFactory
        .instance
        .analyticManager
            .trackEvent(.staking(.mainBuyTap))
    }
    
    func openDeposit(neutrinoAsset: DomainLayer.DTO.Asset) {
        let coordinator = StakingTransferCoordinator(router: self.navigationRouter, kind: .deposit)
        coordinator.delegate = self
        addChildCoordinator(childCoordinator: coordinator)
        coordinator.start()
        
        UseCasesFactory
        .instance
        .analyticManager
            .trackEvent(.staking(.mainDepositTap))
    }
    
    func openActionMenu() {

        UseCasesFactory
            .instance
            .analyticManager
            .trackEvent(.wavesQuickAction(.wavesActionPanel))
        
        let vc = StoryboardScene.Waves.wavesPopupViewController.instantiate()
        vc.moduleOutput = self
        let popup = PopupViewController()
        popup.contentHeight = 204
        popup.present(contentViewController: vc)

    }
    
    func openWithdraw(neutrinoAsset: DomainLayer.DTO.Asset) {
        let coordinator = StakingTransferCoordinator(router: self.navigationRouter, kind: .withdraw)
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
    
    func presentSearchScreen(from startPoint: CGFloat, assets: [DomainLayer.DTO.SmartAssetBalance]) {
        
        UseCasesFactory
            .instance
            .analyticManager
            .trackEvent(.walletHome(.tokenSearch))
        
        if let vc = WalletSearchModuleBuilder(output: self).build(input: assets) as? WalletSearchViewController {
            vc.modalPresentationStyle = .custom
            navigationRouter.present(vc, animated: false) {
                vc.showWithAnimation(fromStartPosition: startPoint)
            }
        }
    }

    func showWalletSort(balances: [DomainLayer.DTO.SmartAssetBalance]) {
        
        UseCasesFactory
            .instance
            .analyticManager
            .trackEvent(.walletHome(.tokenSortingPage))
        
        let vc = WalletSortModuleBuilder().build(input: balances)
        navigationRouter.pushViewController(vc)
    }

    func showMyAddress() {
        
        UseCasesFactory
            .instance
            .analyticManager
            .trackEvent(.walletHome(.qrCard))
        
        let vc = MyAddressModuleBuilder(output: self).build()
        self.myAddressVC = vc
        navigationRouter.pushViewController(vc)
    }

    func showAsset(with currentAsset: DomainLayer.DTO.SmartAssetBalance, assets: [DomainLayer.DTO.SmartAssetBalance]) {

        let vc = AssetDetailModuleBuilder(output: self)
            .build(input: .init(assets: assets,
                                currentAsset: currentAsset))
        
        navigationRouter.pushViewController(vc)
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

    func showLeasingTransaction(transactions: [DomainLayer.DTO.SmartTransaction], index: Int) {

        let coordinator = TransactionCardCoordinator(transaction: transactions[index],
                                                     router: navigationRouter)
        coordinator.delegate = self

        addChildCoordinatorAndStart(childCoordinator: coordinator)
    }
}

// MARK: - WalletSearchViewControllerDelegate
extension WalletCoordinator: WalletSearchViewControllerDelegate {
    
    func walletSearchViewControllerDidTapCancel(_ searchController: WalletSearchViewController) {
        searchController.dismiss()
    }
    
    func walletSearchViewControllerDidSelectAsset(_ asset: DomainLayer.DTO.SmartAssetBalance,
                                                  assets: [DomainLayer.DTO.SmartAssetBalance]) {
        
        navigationRouter.dismiss(animated: false, completion: nil)
        let vc = AssetDetailModuleBuilder(output: self)
            .build(input: .init(assets: assets, currentAsset: asset))
        
        navigationRouter.pushViewController(vc)
    }
}

// MARK: AssetModuleOutput

extension WalletCoordinator: AssetDetailModuleOutput {
    func showTrade(asset: DomainLayer.DTO.Asset) {
        
        let coordinator = TradeCoordinator(navigationRouter: navigationRouter, selectedAsset: asset)
        addChildCoordinatorAndStart(childCoordinator: coordinator)
    }
    

    func showSend(asset: DomainLayer.DTO.SmartAssetBalance) {
        let vc = SendModuleBuilder().build(input: .selectedAsset(asset))
        navigationRouter.pushViewController(vc)
    }
    
    func showReceive(asset: DomainLayer.DTO.SmartAssetBalance) {
        let vc = ReceiveContainerModuleBuilder().build(input: asset)
        navigationRouter.pushViewController(vc)
    }
    
    func showHistory(by assetId: String) {
        let historyCoordinator = HistoryCoordinator(navigationRouter: navigationRouter, historyType: .asset(assetId))
        addChildCoordinatorAndStart(childCoordinator: historyCoordinator)
    }

    func showTransaction(transactions: [DomainLayer.DTO.SmartTransaction], index: Int) {

        let coordinator = TransactionCardCoordinator(transaction: transactions[index],
                                                     router: navigationRouter)


        addChildCoordinatorAndStart(childCoordinator: coordinator)
    }
    
    func showBurn(asset: DomainLayer.DTO.SmartAssetBalance, delegate: TokenBurnTransactionDelegate?) {
        
        let vc = StoryboardScene.Asset.tokenBurnViewController.instantiate()
        vc.asset = asset
        vc.delegate = delegate
        navigationRouter.pushViewController(vc)
        
        UseCasesFactory.instance.analyticManager.trackEvent(.tokenBurn(.tap))
    }
}

// MARK: - TransactionCardCoordinatorDelegate
extension WalletCoordinator: TransactionCardCoordinatorDelegate {
    func transactionCardCoordinatorCanceledLeasing() {
        walletViewContoller.viewWillAppear(false)
    }
}

// MARK: - StartLeasingModuleOutput
extension WalletCoordinator: StartLeasingModuleOutput {
    func startLeasingDidSuccess(transaction: DomainLayer.DTO.SmartTransaction, kind: StartLeasingTypes.Kind) {}
}

fileprivate extension AssetDetailModuleBuilder.Input {

    init(assets: [DomainLayer.DTO.SmartAssetBalance],
         currentAsset: DomainLayer.DTO.SmartAssetBalance) {
        self.assets = assets.map { .init(asset: $0) }
        self.currentAsset = .init(asset: currentAsset)
    }
}

fileprivate extension AssetDetailTypes.DTO.Asset.Info {

    init(asset: DomainLayer.DTO.SmartAssetBalance) {
        id = asset.asset.id
        issuer = asset.asset.sender
        name = asset.asset.name
        displayName = asset.asset.displayName
        description = asset.asset.description
        issueDate = asset.asset.timestamp
        isReusable = asset.asset.isReusable
        isMyWavesToken = asset.asset.isMyWavesToken
        isWavesToken = asset.asset.isWavesToken
        isWaves = asset.asset.isWaves
        isFavorite = asset.settings.isFavorite
        isFiat = asset.asset.isFiat
        isSpam = asset.asset.isSpam
        isGateway = asset.asset.isGateway
        sortLevel = asset.settings.sortLevel
        icon = asset.asset.iconLogo
        assetBalance = asset
    }
}


// MARK: MyAddressModuleOutput

extension WalletCoordinator: MyAddressModuleOutput {
    func myAddressShowAliases(_ aliases: [DomainLayer.DTO.Alias]) {

        if aliases.isEmpty {
            let controller = StoryboardScene.Profile.aliasWithoutViewController.instantiate()
            controller.delegate = self
            let popup = PopupViewController()
            popup.contentHeight = Constants.popoverHeight
            popup.present(contentViewController: controller)
            self.currentPopup = popup
        } else {
            let controller = AliasesModuleBuilder.init(output: self).build(input: .init(aliases: aliases))
            let popup = PopupViewController()
            popup.present(contentViewController: controller)
            self.currentPopup = popup
        }
    }
}

// MARK: AliasesModuleOutput

extension WalletCoordinator: AliasesModuleOutput {
    func aliasesCreateAlias() {

        self.currentPopup?.dismissPopup { [weak self] in
            guard let self = self else { return }

            let vc = CreateAliasModuleBuilder(output: self).build()
            self.navigationRouter.pushViewController(vc)
            
            UseCasesFactory.instance.analyticManager.trackEvent(.alias(.aliasCreateVcard))
        }
    }
}

// MARK: AliasWithoutViewControllerDelegate

extension WalletCoordinator: AliasWithoutViewControllerDelegate {
    func aliasWithoutUserTapCreateNewAlias() {
        self.currentPopup?.dismissPopup { [weak self] in
            guard let self = self else { return }

            let vc = CreateAliasModuleBuilder(output: self).build()
            self.navigationRouter.pushViewController(vc)
            
            UseCasesFactory.instance.analyticManager.trackEvent(.alias(.aliasCreateVcard))
        }
    }
}

// MARK: CreateAliasModuleOutput

extension WalletCoordinator: CreateAliasModuleOutput {
    func createAliasCompletedCreateAlias(_ alias: String) {
        if let myAddressVC = self.myAddressVC {
            navigationRouter.popToViewController(myAddressVC)
        }
    }
}

// MARK: - WavesPopupModuleOutput

extension WalletCoordinator: WavesPopupModuleOutput {

    func showSend() {
                        
        UseCasesFactory
            .instance
            .analyticManager
            .trackEvent(.wavesQuickAction(.wavesActionSend))
        
        let vc = SendModuleBuilder().build(input: .empty)
        navigationRouter.pushViewController(vc)
    }

    func showReceive() {

        UseCasesFactory
            .instance
            .analyticManager
            .trackEvent(.wavesQuickAction(.wavesActionReceive))
        
        let vc = ReceiveContainerModuleBuilder().build(input: nil)
        navigationRouter.pushViewController(vc, animated: true)    
    }
}


// MARK: StakingTransferCoordinatorDelegate

extension WalletCoordinator: StakingTransferCoordinatorDelegate {
        
    func stakingTransferSendDepositCompled() {
        walletViewContoller.refreshData()
    }
    
    func stakingTransferSendWithdrawCompled() {
        walletViewContoller.refreshData()
    }
    
    func stakingTransferSendCardCompled() {
        walletViewContoller.refreshData()
    }
}
