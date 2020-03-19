//
//  ReceiveAddressModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/13/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit
import Extensions

class ReceiveAddressModuleBuilder: ModuleBuilderOutput {
  
    weak var output: ReceiveAddressViewControllerModuleOutput?
    
    init(output: ReceiveAddressViewControllerModuleOutput?) {
        self.output = output
    }
    
    func build(input: ReceiveAddress.ViewModel.DisplayData) -> UIViewController {
        
        let vc = StoryboardScene.Receive.receiveAddressViewController.instantiate()
        vc.moduleOutput = output
        vc.moduleInput = input
        return vc
    }
}
