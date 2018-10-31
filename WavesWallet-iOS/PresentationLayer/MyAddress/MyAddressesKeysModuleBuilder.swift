//
//  AddressesKeysModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 27/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct MyAddressesKeysModuleBuilder: ModuleBuilderOutput {

    struct Input: MyAddressesKeysModuleInput {
        let wallet: DomainLayer.DTO.Wallet
    }

    var output: MyAddressesKeysModuleOutput

    func build(input: Input) -> UIViewController {

        let vc = StoryboardScene.Profile.addressesKeysViewController.instantiate()
        let presenter = MyAddressesKeysPresenter()
        presenter.moduleInput = input
        presenter.moduleOutput = output
        vc.presenter = presenter

        return vc
    }
}
