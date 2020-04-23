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
        let weGatewayUseCase = UseCasesFactory.instance.weGatewayUseCase
        let environment = UseCasesFactory.instance.repositories.environmentRepository

        let interactor = ReceiveCryptocurrencyInteractor(authorization: authorization,
                                                         coinomatRepository: coinomatRepository,
                                                         gatewayRepository: gatewayRepository,
                                                         weGatewayUseCase: weGatewayUseCase,
                                                         environment: environment)

        let presenter = ReceiveCryptocurrencyPresenter()
        presenter.interactor = interactor

        let vc = StoryboardScene.Receive.receiveCryptocurrencyViewController.instantiate()
        vc.presenter = presenter
        vc.input = input

        return vc
    }
}
