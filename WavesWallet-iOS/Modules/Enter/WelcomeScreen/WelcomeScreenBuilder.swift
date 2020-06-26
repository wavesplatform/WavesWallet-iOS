// 
//  WelcomeScreenBuilder.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 19.06.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import AppTools
import UITools

final class WelcomeScreenBuilder: WelcomeScreenBuildable {
    func build(with listener: WelcomeScreenListener) -> WelcomeScreenViewController {
        // MARK: - Dependency

        // let dependency = ...

        // MARK: - Instantiating

        let presenter = WelcomeScreenPresenter()
        let interactor = WelcomeScreenInteractor(presenter: presenter)
        interactor.listener = listener
        
        let viewController = WelcomeScreenViewController.instantiateFromStoryboard()
        viewController.interactor = interactor

        // MARK: - Binding

        VIPBinder.bind(interactor: interactor, presenter: presenter, view: viewController)

        return viewController
    }
}
