//
//  ReceiveContainerModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/2/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import UIKit

struct ReceiveContainerModuleBuilder: ModuleBuilder {
    func build(input: DomainLayer.DTO.SmartAssetBalance?) -> UIViewController {
        let vc = StoryboardScene.Receive.receiveContainerViewController.instantiate()
        let showAllList = true

        if let asset = input {
            if input?.asset.isWaves == true {
                vc.add(ReceiveInvoiceModuleBuilder().build(input: .init(filters: [],
                                                                        selectedAsset: asset,
                                                                        showAllList: showAllList)), state: .invoice)
            } else if input?.asset.isFiat == true {
                vc.add(ReceiveInvoiceModuleBuilder().build(input: .init(filters: [],
                                                                        selectedAsset: asset,
                                                                        showAllList: showAllList)), state: .invoice)
            } else {
                if input?.asset.isGeneral == true {
                    vc.add(ReceiveCryptocurrencyModuleBuilder().build(input: .init(filters: [],
                                                                                   selectedAsset: asset,
                                                                                   showAllList: showAllList)),
                           state: .cryptoCurrency)
                }

                vc.add(ReceiveInvoiceModuleBuilder().build(input: .init(filters: [],
                                                                        selectedAsset: asset,
                                                                        showAllList: showAllList)), state: .invoice)
            }
        } else {
            vc.add(ReceiveCryptocurrencyModuleBuilder().build(input: .init(filters: [.cryptoCurrency],
                                                                           selectedAsset: nil,
                                                                           showAllList: showAllList)), state: .cryptoCurrency)

            vc.add(ReceiveInvoiceModuleBuilder().build(input: .init(filters: [.waves, .cryptoCurrency, .fiat, .wavesToken],
                                                                    selectedAsset: nil,
                                                                    showAllList: showAllList)), state: .invoice)
        }

        return vc
    }
}
