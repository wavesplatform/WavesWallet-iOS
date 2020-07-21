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

    func build(input: Void) -> InvestmentViewController {
        let vc = StoryboardScene.Investment.investmentViewController.instantiate()

        let presenter = InvestmentPresenter(kind: .staking)

        let enviroment = UseCasesFactory.instance.repositories.developmentConfigsRepository
        let authUseCase = UseCasesFactory.instance.authorization
        let massTransferRepository = UseCasesFactory.instance.repositories.massTransferRepository        
        let accountSettingsRepository = UseCasesFactory.instance.repositories.accountSettingsRepository
        let stakingBalanceService = UseCasesFactory.instance.repositories.stakingBalanceService
        let serverEnvironmentUseCase = UseCasesFactory.instance.serverEnvironmentUseCase

        let assetsRepository = UseCasesFactory.instance.repositories.assetsRepositoryRemote
            
        let interactor = InvestmentInteractor(enviroment: enviroment,
                                              massTransferRepository: massTransferRepository,
                                              assetsRepository: assetsRepository,
                                              stakingBalanceService: stakingBalanceService,
                                              authorizationInteractor: authUseCase,
                                              accountBalanceInteractor: UseCasesFactory.instance.accountBalance,
                                              accountSettingsRepository: accountSettingsRepository,
                                              leasingInteractor: UseCasesFactory.instance.transactions,
                                              serverEnvironmentUseCase: serverEnvironmentUseCase)

        presenter.interactor = interactor
        presenter.moduleOutput = output
        vc.presenter = presenter

        return vc
    }
}
