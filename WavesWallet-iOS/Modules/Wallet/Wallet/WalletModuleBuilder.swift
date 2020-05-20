//
//  WalletSortModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 02.08.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import UIKit
import WavesSDK

struct WalletModuleBuilder: ModuleBuilderOutput {
    var output: WalletModuleOutput

    func build(input _: Void) -> WalletViewController {
        let vc = StoryboardScene.Wallet.walletViewController.instantiate()

        let presenter = WalletPresenter(kind: .assets)

        let authUseCase = UseCasesFactory.instance.authorization
        let accountSettingsRepository = UseCasesFactory.instance.repositories.accountSettingsRepository

        let interactor = WalletInteractor(authorizationInteractor: authUseCase,
                                          accountBalanceInteractor: UseCasesFactory.instance.accountBalance,
                                          accountSettingsRepository: accountSettingsRepository,
                                          applicationVersionUseCase: UseCasesFactory.instance.applicationVersionUseCase)

        presenter.interactor = interactor
        presenter.moduleOutput = output
        vc.presenter = presenter

        return vc
    }
}
