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
        let blockRepository: BlockRepositoryProtocol = UseCasesFactory.instance.repositories.blockRemote
        let authorizationInteractor: AuthorizationUseCaseProtocol = UseCasesFactory.instance.authorization
        let walletsRepository: WalletsRepositoryProtocol = UseCasesFactory.instance.repositories.walletsRepositoryLocal
        let serverEnvironmentUseCase: ServerEnvironmentRepository = UseCasesFactory.instance.serverEnvironmentUseCase

        let vc = StoryboardScene.Profile.profileViewController.instantiate()
        let presenter = ProfilePresenter(blockRepository: blockRepository,
                                         authorizationInteractor: authorizationInteractor,
                                         walletsRepository: walletsRepository,
                                         serverEnvironmentUseCase: serverEnvironmentUseCase)
        presenter.moduleOutput = output
        vc.presenter = presenter

        return vc
    }
}
