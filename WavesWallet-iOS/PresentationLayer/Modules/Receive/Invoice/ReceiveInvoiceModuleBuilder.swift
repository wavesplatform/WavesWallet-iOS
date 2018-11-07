//
//  ReceiveInvoiceModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/13/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct ReceiveInvoiceModuleBuilder: ModuleBuilder {
    
    func build(input: AssetList.DTO.Input) -> UIViewController {
        
        let vc = StoryboardScene.Receive.receiveInvoiceViewController.instantiate()
        vc.input = input
        return vc
    }
}
