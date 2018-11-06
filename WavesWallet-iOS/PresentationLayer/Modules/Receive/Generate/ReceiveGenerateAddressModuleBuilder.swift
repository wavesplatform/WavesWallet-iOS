//
//  ReceiveGenerateAddressModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/6/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct ReceiveGenerateAddressModuleBuilder: ModuleBuilder {

    func build(input: ReceiveGenerate.DTO.GenerateType) -> UIViewController {
        
        let vc = StoryboardScene.Receive.receiveGenerateAddressViewController.instantiate()
        vc.input = input
        
        return vc
    }
}
