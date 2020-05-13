//
//  MyOrdersModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 20.12.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation

struct MyOrdersModuleBuilder: ModuleBuilder {
    func build(input _: Void) -> UIViewController {
        let vc = StoryboardScene.Dex.myOrdersViewController.instantiate()

        let dexOrderBookRepository = UseCasesFactory.instance.repositories.dexOrderBookRepository
        let authorizationUseCase = UseCasesFactory.instance.authorization
        let serverEnvironmentUseCase = UseCasesFactory.instance.serverEnvironmentUseCase

        vc.system = MyOrdersSystem(dexOrderBookRepository: dexOrderBookRepository,
                                   authorizationUseCase: authorizationUseCase,
                                   serverEnvironmentUseCase: serverEnvironmentUseCase)

        return vc
    }
}
