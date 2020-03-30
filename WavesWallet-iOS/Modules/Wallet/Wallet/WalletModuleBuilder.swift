//
//  WalletSortModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 02.08.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import UIKit
import Extensions
import WavesSDK

struct WalletModuleBuilder: ModuleBuilderOutput {
    var output: WalletModuleOutput

    // input it ts isDisplayInvesting
    func build(input: Bool) -> UIViewController {
        let vc = StoryboardScene.Wallet.walletViewController.instantiate()
        let presenter = WalletPresenter()

        let enviroment = UseCasesFactory.instance.repositories.developmentConfigsRepository
        let authUseCase = UseCasesFactory.instance.authorization
        let massTransferRepository = UseCasesFactory.instance.repositories.massTransferRepository
        let assetsUseCase = UseCasesFactory.instance.assets
        let accountSettingsRepository = UseCasesFactory.instance.repositories.accountSettingsRepository
        let stakingBalanceService = UseCasesFactory.instance.repositories.stakingBalanceService
        
        let interactor = WalletInteractor(enviroment: enviroment,
                                          massTransferRepository: massTransferRepository,
                                          assetUseCase: assetsUseCase,
                                          stakingBalanceService: stakingBalanceService,
                                          authorizationInteractor: authUseCase,
                                          accountBalanceInteractor: UseCasesFactory.instance.accountBalance,
                                          accountSettingsRepository: accountSettingsRepository,
                                          applicationVersionUseCase: UseCasesFactory.instance.applicationVersionUseCase,
                                          leasingInteractor: UseCasesFactory.instance.transactions,
                                          walletsRepository: UseCasesFactory.instance.repositories.walletsRepositoryLocal)

        presenter.interactor = interactor
        presenter.moduleOutput = output
        vc.presenter = presenter
        vc.isDisplayInvesting = input

        return vc
    }
}
