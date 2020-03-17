//
//  ReceiveGenerateAddressModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/6/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit
import Extensions

struct ReceiveGenerateAddressModuleBuilder: ModuleBuilder {

    func build(input: ReceiveGenerateAddress.DTO.GenerateType) -> UIViewController {
        
        let vc = StoryboardScene.Receive.receiveGenerateAddressViewController.instantiate()
        vc.input = input
        
        return vc
    }
}
