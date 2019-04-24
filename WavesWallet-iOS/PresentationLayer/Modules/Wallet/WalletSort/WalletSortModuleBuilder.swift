//
//  NewWalletSortModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/17/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

struct WalletSortModuleBuilder: ModuleBuilder {
    
    func build(input: [DomainLayer.DTO.SmartAssetBalance]) -> UIViewController {
        
        let vc = StoryboardScene.Wallet.walletSortViewController.instantiate()
        var presenter: WalletSortPresenterProtocol = WalletSortPresenter(input: input)
        presenter.interactor = WalletSortInteractor()
        vc.presenter = presenter

        return vc
    }
}
