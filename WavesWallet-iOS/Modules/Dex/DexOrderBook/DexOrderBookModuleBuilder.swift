//
//  DexOrderBookModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/15/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import UIKit
import Extensions

struct DexOrderBookModuleBuilder: ModuleBuilderOutput {
    
    weak var output: DexOrderBookModuleOutput?
    
    func build(input: DexTraderContainer.DTO.Pair) -> UIViewController {
        
        let accountBalance = UseCasesFactory.instance.accountBalance
        let dexOrderBookRepository = UseCasesFactory.instance.repositories.dexOrderBookRepository
        let lastTradesRespository = UseCasesFactory.instance.repositories.lastTradesRespository
        let authorization = UseCasesFactory.instance.authorization
        let assetsRepository = UseCasesFactory.instance.repositories.assetsRepository
        let serverEnvironmentUseCase = UseCasesFactory.instance.serverEnvironmentUseCase
       
        let interactor = DexOrderBookInteractor(pair: input,
                                                accountBalance: accountBalance,
                                                dexOrderBookRepository: dexOrderBookRepository,
                                                lastTradesRespository: lastTradesRespository,
                                                authorization: authorization,
                                                assetsRepository: assetsRepository,
                                                serverEnvironmentUseCase: serverEnvironmentUseCase)
        
        let presenter = DexOrderBookPresenter.init(interactor: interactor,
                                                   priceAsset: input.priceAsset,
                                                   amountAsset: input.amountAsset)
        presenter.moduleOutput = output

        let vc = StoryboardScene.Dex.dexOrderBookViewController.instantiate()
        vc.presenter = presenter
        return vc
    }
    
}
