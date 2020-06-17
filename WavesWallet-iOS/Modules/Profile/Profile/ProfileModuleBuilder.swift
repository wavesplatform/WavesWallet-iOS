//
//  ProfileModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 04/10/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import UIKit

struct ProfileModuleBuilder: ModuleBuilderOutput {
    var output: ProfileModuleOutput

    func build(input _: Void) -> UIViewController {
        // MARK: - Dependencies

        let blockRepository = UseCasesFactory.instance.repositories.blockRemote
        let authorizationInteractor = UseCasesFactory.instance.authorization
        let walletsRepository = UseCasesFactory.instance.repositories.walletsRepositoryLocal
        let serverEnvironmentUseCase = UseCasesFactory.instance.serverEnvironmentUseCase
        
        // MARK: - Intialization

        let presenter = ProfilePresenter(blockRepository: blockRepository,
                                         authorizationInteractor: authorizationInteractor,
                                         walletsRepository: walletsRepository,
                                         serverEnvironmentUseCase: serverEnvironmentUseCase)
        presenter.moduleOutput = output

        let vc = StoryboardScene.Profile.profileViewController.instantiate()
        vc.presenter = presenter

        return vc
    }
}
