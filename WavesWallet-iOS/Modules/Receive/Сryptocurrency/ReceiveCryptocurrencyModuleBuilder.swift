//
//  ReceiveCryptocurrencyModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/6/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import UIKit

struct ReceiveCryptocurrencyModuleBuilder: ModuleBuilder {
    func build(input: AssetList.DTO.Input) -> UIViewController {
        let authorization = UseCasesFactory.instance.authorization
        let coinomatRepository = UseCasesFactory.instance.repositories.coinomatRepository
        let gatewayRepository = UseCasesFactory.instance.repositories.gatewayRepository
        let serverEnvironmentUseCase = UseCasesFactory.instance.serverEnvironmentUseCase
 
        let environmentRepository = UseCasesFactory.instance.repositories.environmentRepository
        let gatewaysWavesRepository = UseCasesFactory.instance.repositories.gatewaysWavesRepository
        let weOAuthRepository = UseCasesFactory.instance.repositories.weOAuthRepository
        
        let interactor = ReceiveCryptocurrencyInteractor(authorization: authorization,
                                                         coinomatRepository: coinomatRepository,
                                                         gatewayRepository: gatewayRepository,                                                         
                                                         serverEnvironmentUseCase: serverEnvironmentUseCase,
                                                         environmentRepository: environmentRepository,
                                                         gatewaysWavesRepository: gatewaysWavesRepository,
                                                         weOAuthRepository: weOAuthRepository)

        let presenter = ReceiveCryptocurrencyPresenter()
        presenter.interactor = interactor

        let vc = StoryboardScene.Receive.receiveCryptocurrencyViewController.instantiate()
        vc.presenter = presenter
        vc.input = input

        return vc
    }
}
