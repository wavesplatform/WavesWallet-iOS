//
//  DexCreateOrderModuleOutput.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/21/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit

protocol DexCreateOrderModuleOutput: AnyObject {
    
    func dexCreateOrderDidCreate(output: DexCreateOrder.DTO.Output)
    
    func dexCreateOrderWarningForPrice(isPriceHigherMarket: Bool, callback: @escaping ((_ isSuccess: Bool) -> Void))

    func dexCreatOrderDidTapMarketTypeInfo()
    
    func dexCreateOrderDidPresentAlert(_ alert: UIViewController)
    func dexCreateOrderDidDismisAlert()
}

protocol DexCreateOrderProtocol {
    func updateCreatedOrders()
}

protocol DexCancelOrderProtocol {
    func updateCanceledOrders()
}
