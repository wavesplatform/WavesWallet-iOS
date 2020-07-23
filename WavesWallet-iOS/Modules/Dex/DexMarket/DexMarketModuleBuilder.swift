//
//  DexMarketModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/9/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit
import Extensions
import DomainLayer

struct DexMarketModuleBuilder: ModuleBuilderOutput {
    
    weak var output: TradeRefreshOutput?
   
    func build(input: DomainLayer.DTO.Dex.Asset?) -> UIViewController {
        
        let vc = StoryboardScene.Dex.dexMarketViewController.instantiate()
                
        let dexRealmRepository = UseCasesFactory.instance.repositories.dexRealmRepository
        let authorizationUseCase = UseCasesFactory.instance.authorization
        let environmentRepository = UseCasesFactory.instance.repositories.environmentRepository
        let dexOrderBookRepository = UseCasesFactory.instance.repositories.dexOrderBookRepository
        let dexPairsPriceRepository = UseCasesFactory.instance.repositories
            .dexPairsPriceRepository
        let assetsRepository = UseCasesFactory.instance.repositories.assetsRepository
        let correctionPairsUseCase = UseCasesFactory.instance.correctionPairsUseCase
        let serverEnvironmentUseCase = UseCasesFactory.instance.serverEnvironmentUseCase
                        
        var presenter: DexMarketPresenterProtocol = DexMarketPresenter(selectedAsset: input)
        presenter.interactor = DexMarketInteractor(dexRealmRepository: dexRealmRepository,
                                                   authorizationUseCase: authorizationUseCase,
                                                   environmentRepository: environmentRepository,
                                                   dexOrderBookRepository: dexOrderBookRepository,
                                                   dexPairsPriceRepository: dexPairsPriceRepository,
                                                   assetsRepository: assetsRepository,
                                                   correctionPairsUseCase: correctionPairsUseCase,
                                                   serverEnvironmentUseCase: serverEnvironmentUseCase)
        vc.presenter = presenter
        vc.delegate = output
        vc.selectedAsset = input
        
        return vc
    }
}
