//
//  TransactionCardBuilder.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 13/03/2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import UIKit

struct TransactionCardBuilder: ModuleBuilderOutput {
    struct Input {
        var kind: TransactionCard.Kind
        var callbackInput: (TransactionCardModuleInput) -> Void
    }

    var output: TransactionCardModuleOutput

    func build(input: Input) -> UIViewController {
        let vc = StoryboardScene.TransactionCard.transactionCardViewController.instantiate()

        let authorizationUseCase = UseCasesFactory.instance.authorization
        let transactionsUseCase = UseCasesFactory.instance.transactions
        let assetsRepository = UseCasesFactory.instance.repositories.assetsRepository
        let dexOrderBookRepository = UseCasesFactory.instance.repositories
            .dexOrderBookRepository
        let orderbookUsecase = UseCasesFactory.instance.oderbook
        let serverEnvironmentUseCase = UseCasesFactory.instance.serverEnvironmentUseCase

        vc.system = TransactionCardSystem(kind: input.kind,
                                          authorizationUseCase: authorizationUseCase,
                                          transactionsUseCase: transactionsUseCase, assetsRepository: assetsRepository,
                                          dexOrderBookRepository: dexOrderBookRepository, orderbookUsecase: orderbookUsecase,
                                          serverEnvironmentUseCase: serverEnvironmentUseCase)
        vc.delegate = output
        input.callbackInput(vc)
        return vc
    }
}
