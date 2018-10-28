//
//  WalletCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 24.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class WalletCoordinator {

    private lazy var historyCoordinator: HistoryCoordinator = HistoryCoordinator()

    private lazy var walletViewContoller: UIViewController = {
        return WalletModuleBuilder(output: self).build()
    }()

    private var navigationController: UINavigationController!

    func start(navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigationController.pushViewController(walletViewContoller, animated: false)
    }
}

extension WalletCoordinator: WalletModuleOutput {

    func showWalletSort() {
        let vc = WalletSortModuleBuilder().build()
        navigationController.pushViewController(vc, animated: true)
    }

    func showMyAddress() {
        let vc = StoryboardScene.Main.myAddressViewController.instantiate()
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

extension WalletCoordinator: AssetModuleOutput {

    func showSend(asset: DomainLayer.DTO.AssetBalance) {
        
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

//MARK: - StartLeasingModuleOutput
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

