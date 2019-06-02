//
//  WalletSearchModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/2/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit

struct WalletSearchModuleBuilder: ModuleBuilder {
    
    
    func build(input: [DomainLayer.DTO.SmartAssetBalance]) -> UIViewController {
        let vc = StoryboardScene.Wallet.walletSearchViewController.instantiate()
        vc.assets = input
        vc.modalPresentationStyle = .custom;
        return vc
    }
}
