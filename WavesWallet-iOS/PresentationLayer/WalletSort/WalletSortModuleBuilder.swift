//
//  WalletSortModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 02.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct WalletSortModuleBuilder: ModuleBuilder {

    func build(input: Void) -> UIViewController {

        let vc = StoryboardScene.Wallet.walletSortViewController.instantiate()
        var presenter: WalletSortPresenterProtocol = WalletSortPresenter()
        presenter.interactor = WalletSortInteractor()
        vc.presenter = presenter
        
        return vc
    }
}
