//
//  SendModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/15/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit
import Extensions
import DomainLayer

struct SendModuleBuilder: ModuleBuilder {

    func build(input: Send.DTO.InputModel) -> UIViewController {

        let accountBalanceUseCase: AccountBalanceUseCaseProtocol = UseCasesFactory.instance.accountBalance
        let assetsRepository = UseCasesFactory.instance.repositories.assetsRepository
        let authorizationUseCase = UseCasesFactory.instance.authorization
        let coinomatRepository = UseCasesFactory.instance.repositories.coinomatRepository
        let aliasRepository = UseCasesFactory.instance.repositories.aliasesRepositoryRemote
        let transactionUseCase: TransactionsUseCaseProtocol = UseCasesFactory.instance.transactions        
        let gatewayRepository = UseCasesFactory.instance.repositories.gatewayRepository
        let gatewaysWavesRepository = UseCasesFactory.instance.repositories.gatewaysWavesRepository
        let weGatewayUseCase = UseCasesFactory.instance.weGatewayUseCase
        let serverEnvironmentUseCase = UseCasesFactory.instance.serverEnvironmentUseCase
        
        let weOAuthRepository = UseCasesFactory.instance.repositories.weOAuthRepository
        
        let interactor: SendInteractorProtocol = SendInteractor(gatewaysWavesRepository: gatewaysWavesRepository,
                                                                assetsRepository: assetsRepository,
                                                                authorizationUseCase: authorizationUseCase,
                                                                coinomatRepository: coinomatRepository,
                                                                aliasRepository: aliasRepository,
                                                                transactionUseCase: transactionUseCase,
                                                                accountBalanceUseCase: accountBalanceUseCase,
                                                                gatewayRepository: gatewayRepository,
                                                                weGatewayUseCase: weGatewayUseCase,
                                                                serverEnvironmentUseCase: serverEnvironmentUseCase,
                                                                weOAuthRepository: weOAuthRepository)
        
        var presenter: SendPresenterProtocol = SendPresenter()
        presenter.interactor = interactor
        
        let vc = StoryboardScene.Send.sendViewController.instantiate()
        
        vc.inputModel = input
        vc.presenter = presenter
        
        return vc
    }
}
