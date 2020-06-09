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

final class WalletCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    weak var parent: Coordinator?

    private lazy var walletViewContoller: WalletViewController = {
        WalletModuleBuilder(output: self).build()
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

        self.authorization
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

extension WalletCoordinator: WalletModuleOutput {
    func openReceive() {
        let vc = ReceiveContainerModuleBuilder().build(input: nil)
        navigationRouter.pushViewController(vc)
    }

    func openSend() {
        let vc = SendModuleBuilder().build(input: .empty)
        navigationRouter.pushViewController(vc)
    }

    func openCard() {
        let buyCrypto = BuyCryptoBuilder()
        let viewController = buyCrypto.build(with: self, selectedAsset: nil)
        
        navigationRouter.pushViewController(viewController)
    }

    func showAccountHistory() {
        let historyCoordinator = HistoryCoordinator(navigationRouter: navigationRouter, historyType: .all)
        addChildCoordinatorAndStart(childCoordinator: historyCoordinator)
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
        myAddressVC = vc
        navigationRouter.pushViewController(vc)
    }

    func showAsset(with currentAsset: DomainLayer.DTO.SmartAssetBalance, assets: [DomainLayer.DTO.SmartAssetBalance]) {
        let vc = AssetDetailModuleBuilder(output: self)
            .build(input: .init(assets: assets,
                                currentAsset: currentAsset))

        navigationRouter.pushViewController(vc)
    }
}

// MARK: - BuyCryptoListener

extension WalletCoordinator: BuyCryptoListener {
    func openUrl(_ url: URL, delegate: BrowserViewControllerDelegate?) {
        BrowserViewController.openURL(url,
                                      toViewController: navigationRouter.navigationController,
                                      delegate: delegate)
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
    func showTrade(asset: Asset) {
        let coordinator = TradeCoordinator(navigationRouter: navigationRouter, selectedAsset: asset)
        addChildCoordinatorAndStart(childCoordinator: coordinator)
    }

    func showSend(asset: DomainLayer.DTO.SmartAssetBalance) {
        let vc = SendModuleBuilder().build(input: .selectedAsset(asset))
        navigationRouter.pushViewController(vc)
    }
        
    func showCard(asset: DomainLayer.DTO.SmartAssetBalance) {
        let buyCryptoBuilder = BuyCryptoBuilder()
        let buyCryptoVC = buyCryptoBuilder.build(with: self, selectedAsset: nil)
        navigationRouter.pushViewController(buyCryptoVC)
    }
    
    func showReceive(asset: DomainLayer.DTO.SmartAssetBalance) {
        let vc = ReceiveContainerModuleBuilder().build(input: asset)
        navigationRouter.pushViewController(vc)
    }

    func showHistory(by assetId: String) {
        let historyCoordinator = HistoryCoordinator(navigationRouter: navigationRouter, historyType: .asset(assetId))
        addChildCoordinatorAndStart(childCoordinator: historyCoordinator)
    }

    func showTransaction(transactions: [SmartTransaction], index: Int) {
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
    func startLeasingDidSuccess(transaction _: SmartTransaction, kind _: StartLeasingTypes.Kind) {}
}

private extension AssetDetailModuleBuilder.Input {
    init(assets: [DomainLayer.DTO.SmartAssetBalance],
         currentAsset: DomainLayer.DTO.SmartAssetBalance) {
        self.assets = assets.map { .init(asset: $0) }
        self.currentAsset = .init(asset: currentAsset)
    }
}

private extension AssetDetailTypes.DTO.Asset.Info {
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
        isQualified = asset.asset.isQualified
        isStablecoin = asset.asset.isStablecoin
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
            currentPopup = popup
        } else {
            let controller = AliasesModuleBuilder(output: self).build(input: .init(aliases: aliases))
            let popup = PopupViewController()
            popup.present(contentViewController: controller)
            currentPopup = popup
        }
    }
}

// MARK: AliasesModuleOutput

extension WalletCoordinator: AliasesModuleOutput {
    func aliasesCreateAlias() {
        currentPopup?.dismissPopup { [weak self] in
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
        currentPopup?.dismissPopup { [weak self] in
            guard let self = self else { return }

            let vc = CreateAliasModuleBuilder(output: self).build()
            self.navigationRouter.pushViewController(vc)

            UseCasesFactory.instance.analyticManager.trackEvent(.alias(.aliasCreateVcard))
        }
    }
}

// MARK: CreateAliasModuleOutput

extension WalletCoordinator: CreateAliasModuleOutput {
    func createAliasCompletedCreateAlias(_: String) {
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
