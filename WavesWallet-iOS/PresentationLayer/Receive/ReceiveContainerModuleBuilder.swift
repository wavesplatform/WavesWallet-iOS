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
            
            if input?.asset?.isWaves == true {
                vc.add(ReceiveInvoiceModuleBuilder().build(input: .init(filters: [], selectedAsset: asset)), state: .invoice)
                vc.add(ReceiveCardModuleBuilder().build(), state: .card)
            }
            else if input?.asset?.isFiat == true {
                vc.add(ReceiveInvoiceModuleBuilder().build(input: .init(filters: [], selectedAsset: asset)), state: .invoice)
            }
            else {
                vc.add(ReceiveCryptocurrencyModuleBuilder().build(input: .init(filters: [], selectedAsset: asset)), state: .cryptoCurrency)
                vc.add(ReceiveInvoiceModuleBuilder().build(input: .init(filters: [], selectedAsset: asset)), state: .invoice)
            }
        }
        else {
            vc.add(ReceiveCryptocurrencyModuleBuilder().build(input: .init(filters: [.cryptoCurrency], selectedAsset: nil)), state: .cryptoCurrency)
            vc.add(ReceiveInvoiceModuleBuilder().build(input: .init(filters: [.waves, .cryptoCurrency, .fiat], selectedAsset: nil)), state: .invoice)
            vc.add(ReceiveCardModuleBuilder().build(), state: .card)
        }
        
        
        return vc
        
    }
}
