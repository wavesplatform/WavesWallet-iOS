//
//  WalletCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 24.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift

private enum Constants {
    static let popoverHeight: CGFloat = 378
}

final class WalletCoordinator: Coordinator {


    var childCoordinators: [Coordinator] = []

    weak var parent: Coordinator?

    private lazy var walletViewContoller: UIViewController = {
        return WalletModuleBuilder(output: self).build()
    }()

    private weak var navigationController: UINavigationController?

    private weak var myAddressVC: UIViewController?

    private var currentPopup: PopupViewController? = nil

    private let disposeBag: DisposeBag = DisposeBag()
    private let authorization: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization

    private var snackBackupSeedKey: String?
    
    init(navigationController: UINavigationController){
        self.navigationController = navigationController
    }

    func start() {

        CATransaction.begin()
        CATransaction.setCompletionBlock {

            self.authorization
                .authorizedWallet()
                .subscribe(onNext: { [weak self] wallet in

                    guard let owner = self else { return }
                    guard wallet.wallet.isAlreadyShowLegalDisplay == false else {
                        owner.showBackupTostIfNeed(isBackedUp: wallet.wallet.isBackedUp)
                        return
                    }

                    let legal = LegalCoordinator(viewController: owner.walletViewContoller)
                    legal.delegate = owner
                    owner.addChildCoordinatorAndStart(childCoordinator: legal)
                })
                .disposed(by: self.disposeBag)            
        }
        navigationController?.pushViewController(walletViewContoller, animated: false)
        CATransaction.commit()
    }
    
    private func showBackupTostIfNeed(isBackedUp: Bool) {
        
        guard let tabBarController = walletViewContoller.tabBarController else { return }
        
        if !isBackedUp {
        
        snackBackupSeedKey = tabBarController.showWarningSnack(title: Localizable.Waves.General.Tost.Savebackup.title,
                                                                subtitle: Localizable.Waves.General.Tost.Savebackup.subtitle,
                                                                icon: Images.warning18White.image, didTap: {
                
                self.authorization.authorizedWallet().subscribe(onNext: { [weak self] (signedWallet) in
                    
                    guard let owner = self else { return }
                    
                    let seed = signedWallet.seedWords
                    
                    let backup = BackupCoordinator(navigationController: owner.navigationController!, seed: seed) { [weak self] _ in
                        
                        guard let owner = self else { return }
                        
                        let wallet = signedWallet.wallet.mutate {
                            $0.isBackedUp = true
                        }
                        owner.authorization.changeWallet(wallet).subscribe(onNext: { (wallet) in
                            
                        }).disposed(by: owner.disposeBag)
                        
                        owner.navigationController?.popToRootViewController(animated: true)
                    }
                    owner.addChildCoordinator(childCoordinator: backup)
                    backup.start()
                }).disposed(by: self.disposeBag)

            }) {}

        }
    }
    
    func removePopupBackupSeedIfNeed() {
        if let key = snackBackupSeedKey {
            SweetSnackbar.shared.hideSnack(key: key)
        }
    }
}

// MARK: WalletModuleOutput

extension WalletCoordinator: WalletModuleOutput {

    func showWalletSort() {
        let vc = WalletSortModuleBuilder().build()
        navigationController?.pushViewController(vc, animated: true)
    }

    func showMyAddress() {
        let vc = MyAddressModuleBuilder(output: self).build()
        self.myAddressVC = vc
        navigationController?.pushViewController(vc, animated: true)
    }

    func showAsset(with currentAsset: WalletTypes.DTO.Asset, assets: [WalletTypes.DTO.Asset]) {

        let vc = AssetModuleBuilder(output: self)
            .build(input: .init(assets: assets,
                                currentAsset: currentAsset))
        
        navigationController?.pushViewController(vc, animated: true)
    }

    func showHistoryForLeasing() {
        guard let navigationController = navigationController else { return }

        let historyCoordinator = HistoryCoordinator(navigationController: navigationController, historyType: .leasing)
        addChildCoordinatorAndStart(childCoordinator: historyCoordinator)
    }
    
    func showStartLease(availableMoney: Money) {
        
        let controller = StartLeasingModuleBuilder(output: self).build(input: availableMoney)
        navigationController?.pushViewController(controller, animated: true)
    }

    func showLeasingTransaction(transactions: [DomainLayer.DTO.SmartTransaction], index: Int) {

        guard let navigationController = navigationController else { return }
        let coordinator = TransactionHistoryCoordinator(transactions: transactions,
                                                        currentIndex: index,
                                                        navigationController: navigationController)
        addChildCoordinatorAndStart(childCoordinator: coordinator)
    }
}

// MARK: AssetModuleOutput

extension WalletCoordinator: AssetModuleOutput {

    func showSend(asset: DomainLayer.DTO.AssetBalance) {
        let vc = SendModuleBuilder().build(input: asset)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showReceive(asset: DomainLayer.DTO.AssetBalance) {
        let vc = ReceiveContainerModuleBuilder().build(input: asset)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showHistory(by assetId: String) {
        guard let navigationController = navigationController else { return }
        let historyCoordinator = HistoryCoordinator(navigationController: navigationController, historyType: .asset(assetId))
        historyCoordinator.start()
    }

    func showTransaction(transactions: [DomainLayer.DTO.SmartTransaction], index: Int) {
        guard let navigationController = navigationController else { return }
        let coordinator = TransactionHistoryCoordinator(transactions: transactions,
                                                        currentIndex: index,
                                                        navigationController: navigationController)
        addChildCoordinatorAndStart(childCoordinator: coordinator)
    }
    
    func showBurn(asset: DomainLayer.DTO.AssetBalance, delegate: TokenBurnTransactionDelegate?) {
        
        let vc = StoryboardScene.Asset.tokenBurnViewController.instantiate()
        vc.asset = asset
        vc.delegate = delegate
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - StartLeasingModuleOutput

extension WalletCoordinator: StartLeasingModuleOutput {
    
    func startLeasingDidSuccess(transaction: DomainLayer.DTO.SmartTransaction, kind: StartLeasingTypes.Kind) {
        
        switch kind {
        case .send(let sendOrder):
        //TODO: need update Money after creating order
        print("TODO: need update Money after creating order")
            
        default:
            break
        }
    }
}

fileprivate extension AssetModuleBuilder.Input {

    init(assets: [WalletTypes.DTO.Asset], currentAsset: WalletTypes.DTO.Asset) {
        self.assets = assets.map { .init(asset: $0) }
        self.currentAsset = .init(asset: currentAsset)
    }
}

fileprivate extension AssetTypes.DTO.Asset.Info {

    init(asset: WalletTypes.DTO.Asset) {
        id = asset.id
        issuer = asset.issuer
        name = asset.name
        description = asset.description
        issueDate = asset.issueDate
        isReusable = asset.isReusable
        isMyWavesToken = asset.isMyWavesToken
        isWavesToken = asset.isWavesToken
        isWaves = asset.isWaves
        isFavorite = asset.isFavorite
        isFiat = asset.isFiat
        isSpam = asset.isSpam
        isGateway = asset.isGateway
        sortLevel = asset.sortLevel
        icon = asset.icon
        assetBalance = asset.assetBalance
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

        self.currentPopup?.dismissPopup {
            let vc = CreateAliasModuleBuilder(output: self).build()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: AliasWithoutViewControllerDelegate

extension WalletCoordinator: AliasWithoutViewControllerDelegate {
    func aliasWithoutUserTapCreateNewAlias() {
        self.currentPopup?.dismissPopup {
            let vc = CreateAliasModuleBuilder(output: self).build()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: CreateAliasModuleOutput

extension WalletCoordinator: CreateAliasModuleOutput {
    func createAliasCompletedCreateAlias(_ alias: String) {
        if let myAddressVC = self.myAddressVC {
            navigationController?.popToViewController(myAddressVC, animated: true)
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

                owner.showBackupTostIfNeed(isBackedUp: wallet.wallet.isBackedUp)

                var newWallet = wallet.wallet
                newWallet.isAlreadyShowLegalDisplay = true

                return owner.authorization.changeWallet(newWallet).map { _ in }
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
}
