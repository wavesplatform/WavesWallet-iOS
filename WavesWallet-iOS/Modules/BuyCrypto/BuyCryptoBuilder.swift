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
    func build() -> BuyCryptoViewController {
        // MARK: - Dependency

        let serverEnvironment = UseCasesFactory.instance.repositories.serverEnvironmentUseCase
        let authorizationService = UseCasesFactory.instance.authorization
        let oauthRepository = UseCasesFactory.instance.repositories.weOAuthRepository
        let gatewayWavesRepository = UseCasesFactory.instance.repositories.gatewaysWavesRepository
        
        // MARK: - Instantiating

        let presenter = BuyCryptoPresenter()
        let interactor = BuyCryptoInteractor(presenter: presenter,
                                             serverEnvironment: serverEnvironment,
                                             authorizationService: authorizationService,
                                             oauthRepository: oauthRepository,
                                             gatewayWavesRepository: gatewayWavesRepository)
        let viewController = BuyCryptoViewController.instantiateFromStoryboard()
        viewController.interactor = interactor

        // MARK: - Binding
        
        VIPBinder.bind(interactor: interactor, presenter: presenter, view: viewController)

        return viewController
    }
}
