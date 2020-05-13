// 
//  BuyCryptoBuilder.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 13.05.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import AppTools
import UITools

final class BuyCryptoBuilder: BuyCryptoBuildable {
    func build() -> BuyCryptoViewController {
        // MARK: - Dependency

        // let dependency = ...

        // MARK: - Instantiating

        let presenter = BuyCryptoPresenter()
        let interactor = BuyCryptoInteractor(presenter: presenter)
        let viewController = BuyCryptoViewController.instantiateFromStoryboard()
        viewController.interactor = interactor

        // MARK: - Binding

        
//        VIPBinder.bind(view: viewController, interactor: interactor, presenter: presenter)

        return viewController
    }
}
