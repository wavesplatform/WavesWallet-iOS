//
//  WalletSearchModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/2/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit
import DomainLayer

struct WalletSearchModuleBuilder: ModuleBuilderOutput {
    
    var output: WalletSearchViewControllerDelegate
    
    func build(input: [DomainLayer.DTO.SmartAssetBalance]) -> UIViewController {
        let vc = StoryboardScene.Wallet.walletSearchViewController.instantiate()
        vc.presenter = WalletSearchPresenter(assets: input)
        vc.delegate = output
        return vc
    }
}
