//
//  WalletCoordinator.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 24.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class WalletCoordinator {
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
}

extension WalletCoordinator: AssetModuleOutput {

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
    }
}

