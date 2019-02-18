//
//  WalletCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 24.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift
import AppsFlyerLib
import FirebaseAnalytics

private enum Constants {
    static let popoverHeight: CGFloat = 378
}

final class WalletCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []

    weak var parent: Coordinator?

    private lazy var walletViewContoller: UIViewController = {
        return WalletModuleBuilder(output: self).build()
    }()

    private var navigationRouter: NavigationRouter

    private weak var myAddressVC: UIViewController?

    private var currentPopup: PopupViewController? = nil

    private let disposeBag: DisposeBag = DisposeBag()
    private let authorization: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization
    private let walletsRepository: WalletsRepositoryProtocol = FactoryRepositories.instance.walletsRepositoryLocal

    init(navigationRouter: NavigationRouter){
        self.navigationRouter = navigationRouter
    }

    func start() {
        setupLifeCycleTost()
        navigationRouter.pushViewController(walletViewContoller, animated: true, completion: nil)
    }

    private func setupLifeCycleTost() {
        walletViewContoller.rx.viewDidAppear.asObservable().subscribe(onNext: { [weak self] _ in
            self?.showLegalOrBackupIfNeed()
        }).disposed(by: disposeBag)

        walletViewContoller.rx.viewDidDisappear.asObservable().subscribe(onNext: { [weak self] _ in
            self?.childCoordinators.first(where: { (coordinator) -> Bool in
                return coordinator is BackupTostCoordinator
            })?.removeFromParentCoordinator()
        }).disposed(by: disposeBag)
    }

    private func showBackupTost() {        
        let coordinator = BackupTostCoordinator(navigationRouter: navigationRouter)
        addChildCoordinatorAndStart(childCoordinator: coordinator)
    }

    private func showNews() {
        let coordinator = AppNewsCoordinator()
        addChildCoordinatorAndStart(childCoordinator: coordinator)
    }

    private func showNewsAndBackupTost() {
        showBackupTost()
        showNews()
    }

    private func showLegalOrBackupIfNeed() {

        self.authorization
            .authorizedWallet()
            .take(1)
            .subscribe(onNext: { [weak self] wallet in
                guard let owner = self else { return }
                guard wallet.wallet.isAlreadyShowLegalDisplay == false else {
                    owner.showNewsAndBackupTost()
                    return
                }

                let legal = LegalCoordinator(viewController: owner.walletViewContoller)
                legal.delegate = owner
                owner.addChildCoordinatorAndStart(childCoordinator: legal)
            })
            .disposed(by: self.disposeBag)
    }
}

// MARK: WalletModuleOutput

extension WalletCoordinator: WalletModuleOutput {

    func showWalletSort(balances: [DomainLayer.DTO.SmartAssetBalance]) {
        let vc = WalletSortModuleBuilder().build(input: balances)
        navigationRouter.pushViewController(vc)
    }

    func showMyAddress() {
        let vc = MyAddressModuleBuilder(output: self).build()
        self.myAddressVC = vc
        navigationRouter.pushViewController(vc)
    }

    func showAsset(with currentAsset: DomainLayer.DTO.SmartAssetBalance, assets: [DomainLayer.DTO.SmartAssetBalance]) {

        let vc = AssetModuleBuilder(output: self)
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
    }

    func showLeasingTransaction(transactions: [DomainLayer.DTO.SmartTransaction], index: Int) {

        let coordinator = TransactionHistoryCoordinator(transactions: transactions,
                                                        currentIndex: index,
                                                        router: navigationRouter)
        addChildCoordinatorAndStart(childCoordinator: coordinator)
    }
}

// MARK: AssetModuleOutput

extension WalletCoordinator: AssetModuleOutput {

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

        let coordinator = TransactionHistoryCoordinator(transactions: transactions,
                                                        currentIndex: index,
                                                        router: navigationRouter)
        addChildCoordinatorAndStart(childCoordinator: coordinator)
    }
    
    func showBurn(asset: DomainLayer.DTO.SmartAssetBalance, delegate: TokenBurnTransactionDelegate?) {
        
        let vc = StoryboardScene.Asset.tokenBurnViewController.instantiate()
        vc.asset = asset
        vc.delegate = delegate
        navigationRouter.pushViewController(vc)
    }
}

// MARK: - StartLeasingModuleOutput

extension WalletCoordinator: StartLeasingModuleOutput {
    
    func startLeasingDidSuccess(transaction: DomainLayer.DTO.SmartTransaction, kind: StartLeasingTypes.Kind) {
        
        switch kind {
        case .send:
            //TODO: Here can be some logic
            break
            
        default:
            break
        }
    }
}

fileprivate extension AssetModuleBuilder.Input {

    init(assets: [DomainLayer.DTO.SmartAssetBalance],
         currentAsset: DomainLayer.DTO.SmartAssetBalance) {
        self.assets = assets.map { .init(asset: $0) }
        self.currentAsset = .init(asset: currentAsset)
    }
}

fileprivate extension AssetTypes.DTO.Asset.Info {

    init(asset: DomainLayer.DTO.SmartAssetBalance) {
        id = asset.asset.id
        issuer = asset.asset.sender
        name = asset.asset.displayName
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

        if aliases.count == 0 {
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
            guard let owner = self else { return }

            let vc = CreateAliasModuleBuilder(output: owner).build()
            self?.navigationRouter.pushViewController(vc)
        }
    }
}

// MARK: AliasWithoutViewControllerDelegate

extension WalletCoordinator: AliasWithoutViewControllerDelegate {
    func aliasWithoutUserTapCreateNewAlias() {
        self.currentPopup?.dismissPopup { [weak self] in
            guard let owner = self else { return }

            let vc = CreateAliasModuleBuilder(output: owner).build()
            self?.navigationRouter.pushViewController(vc)
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

// MARK: LegalCoordinatorDelegate

extension WalletCoordinator: LegalCoordinatorDelegate {

    func legalConfirm() {
        
        authorization
            .authorizedWallet()
            .flatMap({ [weak self] (wallet) -> Observable<Void> in
                guard let owner = self else { return Observable.never() }

                owner.showNewsAndBackupTost()

                var newWallet = wallet.wallet
                newWallet.isAlreadyShowLegalDisplay = true
                owner.sendAnalytics()
                return owner.authorization.changeWallet(newWallet).map { _ in }
            })
            .subscribe()
            .disposed(by: disposeBag)
    }

    private func sendAnalytics() {

        walletsRepository
            .wallets()
            .subscribe(onNext: { (wallets) in
                AppsFlyerTracker.shared().trackEvent("new_wallet", withValues: ["wallets_count": wallets.count]);
                Analytics.logEvent("new_wallet", parameters: ["wallets_count": wallets.count])
        })
        .disposed(by: disposeBag)
    }
}
