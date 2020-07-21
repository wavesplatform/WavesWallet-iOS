//
//  BuyCryptoBuilder.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 13.05.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import AppTools
import DomainLayer
import UITools

final class BuyCryptoBuilder: BuyCryptoBuildable {
    func build(with listener: BuyCryptoListener, selectedAsset: Asset?) -> BuyCryptoViewController {
        // MARK: - Dependency

        let authorizationService = UseCasesFactory.instance.authorization
        let gatewayWavesRepository = UseCasesFactory.instance.repositories.gatewaysWavesRepository
        let adCashGRPCService = UseCasesFactory.instance.repositories.adCashGRPCService
        let environmentRepository = UseCasesFactory.instance.repositories.environmentRepository
        let assetsRepository = UseCasesFactory.instance.repositories.assetsRepository
        let developmentConfigRepository = UseCasesFactory.instance.repositories.developmentConfigsRepository
        let serverEnvironmentRepository = UseCasesFactory.instance.serverEnvironmentUseCase
        let weOAuthRepository = UseCasesFactory.instance.repositories.weOAuthRepository

        // MARK: - Instantiating

        let presenter = BuyCryptoPresenter()
        let interactor = BuyCryptoInteractor(presenter: presenter,
                                             authorizationService: authorizationService,
                                             environmentRepository: environmentRepository,
                                             assetsRepository: assetsRepository,
                                             gatewayWavesRepository: gatewayWavesRepository,
                                             adCashGRPCService: adCashGRPCService,
                                             developmentConfigRepository: developmentConfigRepository,
                                             serverEnvironmentRepository: serverEnvironmentRepository,
                                             weOAuthRepository: weOAuthRepository,
                                             selectedAsset: selectedAsset)
        interactor.listener = listener

        let viewController = BuyCryptoViewController.instantiateFromStoryboard()
        viewController.interactor = interactor

        // MARK: - Binding

        VIPBinder.bind(interactor: interactor, presenter: presenter, view: viewController)

        return viewController
    }
}
