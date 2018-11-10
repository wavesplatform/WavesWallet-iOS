//
//  WalletCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 24.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let popoverHeight: CGFloat = 378
}

final class WalletCoordinator {

    private lazy var historyCoordinator: HistoryCoordinator = HistoryCoordinator()

    private lazy var walletViewContoller: UIViewController = {
        return WalletModuleBuilder(output: self).build()
    }()

    private var navigationController: UINavigationController!

    private weak var myAddressVC: UIViewController?

    private var currentPopup: PopupViewController? = nil

    func start(navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigationController.pushViewController(walletViewContoller, animated: false)
    }
}

// MARK: WalletModuleOutput

extension WalletCoordinator: WalletModuleOutput {

    func showWalletSort() {
        let vc = WalletSortModuleBuilder().build()
        navigationController.pushViewController(vc, animated: true)
    }

    func showMyAddress() {
        let vc = MyAddressModuleBuilder(output: self).build()
        self.myAddressVC = vc
        navigationController.pushViewController(vc, animated: true)
    }

    func showAsset(with currentAsset: WalletTypes.DTO.Asset, assets: [WalletTypes.DTO.Asset]) {

        let vc = AssetModuleBuilder(output: self)
            .build(input: .init(assets: assets,
                                currentAsset: currentAsset))
        
        navigationController.pushViewController(vc, animated: true)
    }

    func showHistoryForLeasing() {
        historyCoordinator.start(navigationController: navigationController, historyType: .leasing)
    }
    
    func showStartLease(availableMoney: Money) {
        
        let controller = StartLeasingModuleBuilder(output: self).build(input: availableMoney)
        navigationController.pushViewController(controller, animated: true)
    }

    func showLeasingTransaction(transactions: [DomainLayer.DTO.SmartTransaction], index: Int) {
        TransactionHistoryCoordinator(transactions: transactions,
                                      currentIndex: index,
                                      rootViewController: walletViewContoller).start()
    }
}

// MARK: AssetModuleOutput

extension WalletCoordinator: AssetModuleOutput {

    func showSend(asset: DomainLayer.DTO.AssetBalance) {
        let vc = SendModuleBuilder().build(input: asset)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showReceive(asset: DomainLayer.DTO.AssetBalance) {
        let vc = ReceiveContainerModuleBuilder().build(input: asset)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showHistory(by assetId: String) {

        historyCoordinator.start(navigationController: navigationController, historyType: .asset(assetId))
    }

    func showTransaction(transactions: [DomainLayer.DTO.SmartTransaction], index: Int) {

        TransactionHistoryCoordinator(transactions: transactions,
                                      currentIndex: index,
                                      rootViewController: walletViewContoller).start()
    }
}

// MARK: - StartLeasingModuleOutput

extension WalletCoordinator: StartLeasingModuleOutput {
    
    func startLeasingDidCreateOrder() {
        
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
            self.navigationController.pushViewController(vc, animated: true)
        }
    }
}

// MARK: AliasWithoutViewControllerDelegate

extension WalletCoordinator: AliasWithoutViewControllerDelegate {
    func aliasWithoutUserTapCreateNewAlias() {
        self.currentPopup?.dismissPopup {
            let vc = CreateAliasModuleBuilder(output: self).build()
            self.navigationController.pushViewController(vc, animated: true)
        }
    }
}

// MARK: CreateAliasModuleOutput

extension WalletCoordinator: CreateAliasModuleOutput {
    func createAliasCompletedCreateAlias(_ alias: String) {
        if let myAddressVC = self.myAddressVC {
            navigationController.popToViewController(myAddressVC, animated: true)
        }
    }
}
