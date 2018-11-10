//
//  ReceiveAddressModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/13/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct ReceiveAddressModuleBuilder: ModuleBuilder {
  
    func build(input: ReceiveAddress.DTO.Info) -> UIViewController {
        
        let vc = StoryboardScene.Receive.receiveAddressViewController.instantiate()
        vc.input = input
        return vc
    }
}
