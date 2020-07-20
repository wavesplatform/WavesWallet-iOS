//
//  StakingTransferModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 24.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import DomainLayer
import Extensions
import UIKit

final class StakingTransferModuleBuilder: ModuleBuilderOutput {
    weak var output: StakingTransferModuleOutput?

    struct Input {
        let assetId: String
        let kind: StakingTransfer.DTO.Kind
    }

    init(output: Output) {
        self.output = output
    }

    func build(input: StakingTransferModuleBuilder.Input) -> UIViewController {
        let vc = StoryboardScene.StakingTransfer.stakingTransferViewController.instantiate()
        vc.moduleOutput = output

        let accountBalanceUseCase = UseCasesFactory.instance.accountBalance
        let assetsUseCase = UseCasesFactory.instance.assets
        let transactionUseCase = UseCasesFactory.instance.transactions
        let authorizationUseCase = UseCasesFactory.instance.authorization
        let developmentConfigsRepository = UseCasesFactory.instance.repositories.developmentConfigsRepository
        let adCashDepositsUseCase = UseCasesFactory.instance.adCashDepositsUseCase
        let stakingBalanceService = UseCasesFactory.instance.repositories.stakingBalanceService
        let userRepository = UseCasesFactory.instance.repositories.userRepository

        let stakingTransferInteractor = StakingTransferInteractor(accountBalanceUseCase: accountBalanceUseCase,
                                                                  assetsUseCase: assetsUseCase,
                                                                  transactionUseCase: transactionUseCase,
                                                                  authorizationUseCase: authorizationUseCase,
                                                                  developmentConfigsRepository: developmentConfigsRepository,
                                                                  adCashDepositsUseCase: adCashDepositsUseCase,
                                                                  stakingBalanceService: stakingBalanceService,
                                                                  userRepository: userRepository)
        
        let system = StakingTransferSystem(assetId: input.assetId, kind: input.kind, interactor: stakingTransferInteractor)
        vc.system = system

        return vc
    }
}
