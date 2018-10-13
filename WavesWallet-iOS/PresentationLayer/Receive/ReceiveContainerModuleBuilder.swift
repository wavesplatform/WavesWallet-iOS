//
//  ReceiveContainerModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/2/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct ReceiveContainerModuleBuilder: ModuleBuilder {
    
    func build(input: DomainLayer.DTO.AssetBalance?) -> UIViewController {
        
        let vc = StoryboardScene.Receive.receiveContainerViewController.instantiate()

        if let asset = input {
            vc.add(ReceiveCryptocurrencyModuleBuilder().build(input: .init(filters: [.cryptoCurrency], selectedAsset: asset)), state: .cryptoCurrency)
            vc.add(StoryboardScene.Receive.receiveInvoiceViewController.instantiate(), state: .invoice)
            vc.add(ReceiveCardModuleBuilder().build(), state: .card)
        }
        else {
            vc.add(ReceiveCryptocurrencyModuleBuilder().build(input: .init(filters: [.cryptoCurrency], selectedAsset: nil)), state: .cryptoCurrency)
            vc.add(StoryboardScene.Receive.receiveInvoiceViewController.instantiate(), state: .invoice)
            vc.add(ReceiveCardModuleBuilder().build(), state: .card)
        }
        
        
        return vc
        
    }
}
