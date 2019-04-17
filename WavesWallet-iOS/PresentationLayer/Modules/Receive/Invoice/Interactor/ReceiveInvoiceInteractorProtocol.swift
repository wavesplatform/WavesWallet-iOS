//
//  ReceiveInvoiceInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/11/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import WavesSDKExtension

protocol ReceiveInvoiceInteractorProtocol {
    func displayInfo(asset: DomainLayer.DTO.Asset, amount: Money) -> Observable<ReceiveInvoice.DTO.DisplayInfo>
}
