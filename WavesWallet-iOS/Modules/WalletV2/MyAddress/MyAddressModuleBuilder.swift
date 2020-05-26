//
//  AddressesKeysModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 27/10/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit
import Extensions

struct MyAddressModuleBuilder: ModuleBuilderOutput {

    var output: MyAddressModuleOutput

    func build(input: Void) -> UIViewController {

        let vc = StoryboardScene.MyAddress.myAddressViewController.instantiate()
        let presenter = MyAddressPresenter()        
        presenter.moduleOutput = output
        vc.presenter = presenter

        return vc
    }
}
