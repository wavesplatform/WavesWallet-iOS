//
//  DexSellBuyModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/11/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import UIKit

struct DexCreateOrderModuleBuilder: ModuleBuilderOutput {
    weak var output: DexCreateOrderModuleOutput?

    func build(input: DexCreateOrder.DTO.Input) -> UIViewController {
        let pair = DomainLayer.DTO.Dex.Pair(amountAsset: input.amountAsset, priceAsset: input.priceAsset)

        let auth = UseCasesFactory.instance.authorization
        let matcherRepository = UseCasesFactory.instance.repositories.matcherRepository
        let orderBookRepository = UseCasesFactory.instance.repositories.dexOrderBookRepository
        let transactionInteractor = UseCasesFactory.instance.transactions
        let orderBookInteractor = UseCasesFactory.instance.oderbook
        let developmentConfig = UseCasesFactory.instance.repositories.developmentConfigsRepository
        let serverEnvironmentUseCase = UseCasesFactory.instance.serverEnvironmentUseCase
        let addressRepository = UseCasesFactory.instance.repositories.addressRepository
        let accountBalance = UseCasesFactory.instance.accountBalance
        let assetRepository = UseCasesFactory.instance.repositories.assetsRepository
        let transactionRepository = UseCasesFactory.instance.repositories.transactionsRepository
        let assetsRepository = UseCasesFactory.instance.repositories.assetsRepository

        let interactor = DexCreateOrderInteractor(authorization: auth,
                                                  addressRepository: addressRepository,
                                                  accountBalance: accountBalance,
                                                  matcherRepository: matcherRepository,
                                                  dexOrderBookRepository: orderBookRepository,
                                                  transactionInteractor: transactionInteractor,
                                                  transactionsRepository: transactionRepository,
                                                  assetsRepository: assetRepository,
                                                  orderBookInteractor: orderBookInteractor,
                                                  developmentConfig: developmentConfig,
                                                  serverEnvironmentUseCase: serverEnvironmentUseCase)

        let presenter = DexCreateOrderPresenter(interactor: interactor, pair: pair)

        let vc = StoryboardScene.Dex.dexCreateOrderViewController.instantiate()
        vc.input = input
        vc.presenter = presenter
        vc.moduleOutput = output

        return vc
    }
}
