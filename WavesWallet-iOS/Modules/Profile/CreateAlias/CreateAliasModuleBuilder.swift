//
//  CreateAliasModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 29/10/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit
import Extensions
import DomainLayer

struct CreateAliasModuleBuilder: ModuleBuilderOutput {

    var output: CreateAliasModuleOutput

    func build(input: Void) -> UIViewController {

        let vc = StoryboardScene.Profile.createAliasViewController.instantiate()
        
        let aliasesRepository = UseCasesFactory.instance.repositories.aliasesRepositoryRemote
        let authorizationUseCase = UseCasesFactory.instance.authorization
        let serverEnvironmentUseCase = UseCasesFactory.instance.serverEnvironmentUseCase
        let transactionsUseCase = UseCasesFactory.instance.transactions
        let accountBalanceUseCase = UseCasesFactory.instance.accountBalance
        
        let presenter = CreateAliasPresenter(aliasesRepository: aliasesRepository,
                                             authorizationUseCase: authorizationUseCase,
                                             serverEnvironmentUseCase: serverEnvironmentUseCase,
                                             transactionsUseCase: transactionsUseCase,
                                             accountBalanceUseCase: accountBalanceUseCase)
        presenter.moduleOutput = output
        vc.presenter = presenter

        return vc
    }
}
