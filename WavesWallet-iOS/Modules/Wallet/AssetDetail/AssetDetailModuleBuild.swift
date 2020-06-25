//
//  AssetModuleBuild.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 06.08.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit
import Extensions
import DomainLayer

struct AssetDetailModuleBuilder: ModuleBuilderOutput {

    struct Input: AssetDetailModuleInput {
        var assets: [AssetDetailTypes.DTO.Asset.Info]
        var currentAsset: AssetDetailTypes.DTO.Asset.Info
    }

    var output: AssetDetailModuleOutput

    func build(input: AssetDetailModuleBuilder.Input) -> UIViewController {

        let presenter = AssetDetailPresenter(input: input)
        let vc = StoryboardScene.Asset.assetViewController.instantiate()
        
        let authorizationInteractor = UseCasesFactory.instance.authorization
        let accountBalanceInteractor = UseCasesFactory.instance.accountBalance

        let transactionsInteractor = UseCasesFactory.instance.transactions

        let assetsBalanceSettings = UseCasesFactory.instance.assetsBalanceSettings

        let gatewaysWavesRepository = UseCasesFactory.instance.repositories.gatewaysWavesRepository

        let weOAuthRepository = UseCasesFactory.instance.repositories.weOAuthRepository
        
        let pairsPriceRepository = UseCasesFactory.instance.repositories.dexPairsPriceRepository

        let serverEnvironmentUseCase = UseCasesFactory.instance.serverEnvironmentUseCase
                
        let adCashGRPCService = UseCasesFactory.instance.repositories.adCashGRPCService
        
        presenter.interactor = AssetDetailInteractor(authorizationInteractor: authorizationInteractor,
                                                     accountBalanceInteractor: accountBalanceInteractor,
                                                     transactionsInteractor: transactionsInteractor,
                                                     assetsBalanceSettings: assetsBalanceSettings,
                                                     gatewaysWavesRepository: gatewaysWavesRepository,
                                                     weOAuthRepository: weOAuthRepository,
                                                     pairsPriceRepository: pairsPriceRepository,
                                                     serverEnvironmentUseCase: serverEnvironmentUseCase,
                                                     adCashGRPCService: adCashGRPCService)
        presenter.moduleOutput = output
        vc.presenter = presenter

        return vc
    }
}
