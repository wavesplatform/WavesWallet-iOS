//
//  ReceiveAddressModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/13/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit
import Extensions

struct ReceiveAddressModuleBuilder: ModuleBuilder {
  
    func build(input: [ReceiveAddress.DTO.Info]) -> UIViewController {
        
        let vc = StoryboardScene.Receive.receiveAddressViewController.instantiate()
        vc.moduleInput = input
        return vc
    }
}
