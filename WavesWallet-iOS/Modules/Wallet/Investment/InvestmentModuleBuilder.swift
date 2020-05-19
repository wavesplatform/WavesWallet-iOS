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

struct InvestmentModuleBuilder: ModuleBuilderOutput {
    var output: InvestmentModuleOutput

    // input it ts isDisplayInvesting
    func build(input: Bool) -> InvestmentViewController {
        let vc = StoryboardScene.Investment.investmentViewController.instantiate()

        let presenter = InvestmentPresenter(kind: input == true ? .staking : .assets)

        let enviroment = UseCasesFactory.instance.repositories.developmentConfigsRepository
        let authUseCase = UseCasesFactory.instance.authorization
        let massTransferRepository = UseCasesFactory.instance.repositories.massTransferRepository
        let assetsUseCase = UseCasesFactory.instance.assets
        let accountSettingsRepository = UseCasesFactory.instance.repositories.accountSettingsRepository
        let stakingBalanceService = UseCasesFactory.instance.repositories.stakingBalanceService
        let serverEnvironmentUseCase = UseCasesFactory.instance.serverEnvironmentUseCase

        let interactor = InvestmentInteractor(enviroment: enviroment,
                                          massTransferRepository: massTransferRepository,
                                          assetUseCase: assetsUseCase,
                                          stakingBalanceService: stakingBalanceService,
                                          authorizationInteractor: authUseCase,
                                          accountBalanceInteractor: UseCasesFactory.instance.accountBalance,
                                          accountSettingsRepository: accountSettingsRepository,
                                          applicationVersionUseCase: UseCasesFactory.instance.applicationVersionUseCase,
                                          leasingInteractor: UseCasesFactory.instance.transactions,
                                          walletsRepository: UseCasesFactory.instance.repositories.walletsRepositoryLocal,
                                          serverEnvironmentUseCase: serverEnvironmentUseCase)

        presenter.interactor = interactor
        presenter.moduleOutput = output
        vc.presenter = presenter
        vc.isDisplayInvesting = input

        return vc
    }
}
