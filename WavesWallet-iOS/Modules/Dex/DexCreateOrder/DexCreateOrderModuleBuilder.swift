//
//  DexSellBuyModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/11/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit
import DomainLayer
import Extensions
 
struct DexCreateOrderModuleBuilder: ModuleBuilderOutput {
    
    weak var output: DexCreateOrderModuleOutput?

    func build(input: DexCreateOrder.DTO.Input) -> UIViewController {
        
        let auth: AuthorizationUseCaseProtocol = UseCasesFactory.instance.authorization
        let matcherRepository: MatcherRepositoryProtocol = UseCasesFactory.instance.repositories.matcherRepository
        let orderBookRepository: DexOrderBookRepositoryProtocol = UseCasesFactory.instance.repositories.dexOrderBookRepository
        let transactionInteractor: TransactionsUseCaseProtocol = UseCasesFactory.instance.transactions
        let assetsInteractor: AssetsUseCaseProtocol = UseCasesFactory.instance.assets
        let orderBookInteractor: OrderBookUseCaseProtocol = UseCasesFactory.instance.oderbook
        let environmentRepository: EnvironmentRepositoryProtocol = UseCasesFactory.instance.repositories.environmentRepository
        let developmentConfig = UseCasesFactory.instance.repositories.developmentConfigsRepository
        let interactor: DexCreateOrderInteractorProtocol = DexCreateOrderInteractor(authorization: auth,
                                                                                    matcherRepository: matcherRepository,
                                                                                    dexOrderBookRepository: orderBookRepository,
                                                                                    transactionInteractor: transactionInteractor,
                                                                                    assetsInteractor: assetsInteractor,
                                                                                    orderBookInteractor: orderBookInteractor,
                                                                                    environmentRepository: environmentRepository,
                                                                                    developmentConfig: developmentConfig)
        
        var presenter: DexCreateOrderPresenterProtocol = DexCreateOrderPresenter()
        presenter.interactor = interactor
        presenter.pair = DomainLayer.DTO.Dex.Pair(amountAsset: input.amountAsset,
                                                  priceAsset: input.priceAsset)
        
        let vc = StoryboardScene.Dex.dexCreateOrderViewController.instantiate()
        vc.input = input
        vc.presenter = presenter
        vc.moduleOutput = output
        
        return vc
    }
}
