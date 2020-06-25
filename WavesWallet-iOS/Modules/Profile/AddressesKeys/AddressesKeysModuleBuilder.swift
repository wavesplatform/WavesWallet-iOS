//
//  AddressesKeysModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 27/10/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit
import DomainLayer
import Extensions

struct AddressesKeysModuleBuilder: ModuleBuilderOutput {

    struct Input: AddressesKeysModuleInput {
        let wallet: Wallet
    }

    var output: AddressesKeysModuleOutput

    func build(input: Input) -> UIViewController {

        let vc = StoryboardScene.Profile.addressesKeysViewController.instantiate()
        
        let authorization = UseCasesFactory.instance.authorization
        let aliasesRepository = UseCasesFactory.instance.repositories.aliasesRepositoryRemote
        let serverEnvironment = UseCasesFactory.instance.serverEnvironmentUseCase
                
        let presenter = AddressesKeysPresenter(authorizationUseCase: authorization,
                                               aliasesRepository: aliasesRepository,
                                               serverEnvironmentRepository: serverEnvironment)
        presenter.moduleInput = input
        presenter.moduleOutput = output
        vc.presenter = presenter

        return vc
    }
}
