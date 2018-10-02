//
//  ReceiveContainerModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/2/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct ReceiveContainerModuleBuilder: ModuleBuilder {
    
    func build(input: Void) -> UIViewController {
        
        let vc = StoryboardScene.Receive.receiveContainerViewController.instantiate()

        vc.add(StoryboardScene.Receive.receiveCryptocurrencyViewController.instantiate())
        vc.add(StoryboardScene.Receive.receiveInvoiceViewController.instantiate())
        vc.add(StoryboardScene.Receive.receiveCardViewController.instantiate())

        return vc
        
    }
}
