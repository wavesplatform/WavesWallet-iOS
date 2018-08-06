//
//  WalletSortModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 02.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct WalletModuleBuilder: ModuleBuilderOutput {

    var output: WalletModuleOutput

    func build(input: Void) -> UIViewController {

        let vc = StoryboardScene.Wallet.walletViewController.instantiate()
        let presenter = WalletPresenter()
        presenter.interactor = WalletInteractor()
        presenter.moduleOutput = output
        vc.presenter = presenter

        return vc
    }
}
