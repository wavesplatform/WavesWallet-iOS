//
//  DexLastTradesModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/16/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import UIKit

struct DexLastTradesModuleBuilder: ModuleBuilderOutput {
    weak var output: DexLastTradesModuleOutput?

    func build(input: DexTraderContainer.DTO.Pair) -> UIViewController {
        let accountBalanceUseCase = UseCasesFactory.instance.accountBalance

        let lastTradesRepository = UseCasesFactory.instance.repositories.lastTradesRespository
        let dexOrderBookRepository = UseCasesFactory.instance.repositories.dexOrderBookRepository
        let authorizationUseCase = UseCasesFactory.instance.authorization
        let assetsRepository = UseCasesFactory.instance.repositories.assetsRepository
        let serverEnvironmentRepository = UseCasesFactory.instance.repositories.serverEnvironmentRepository

        var interactor: DexLastTradesInteractorProtocol = DexLastTradesInteractor(accountBalanceUseCase: accountBalanceUseCase,
                                                                                  lastTradesRepository: lastTradesRepository,
                                                                                  orderBookRepository: dexOrderBookRepository,
                                                                                  authorizationUseCase: authorizationUseCase,
                                                                                  assetsRepository: assetsRepository,
                                                                                  serverEnvironmentRepository: serverEnvironmentRepository)
        interactor.pair = input

        var presenter: DexLastTradesPresenterProtocol = DexLastTradesPresenter()
        presenter.interactor = interactor
        presenter.moduleOutput = output
        presenter.amountAsset = input.amountAsset
        presenter.priceAsset = input.priceAsset

        let vc = StoryboardScene.Dex.dexLastTradesViewController.instantiate()
        vc.presenter = presenter

        return vc
    }
}
