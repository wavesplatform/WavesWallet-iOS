//
//  ReceiveCryptocurrencyInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/5/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift
import DomainLayer

protocol ReceiveCryptocurrencyInteractorProtocol {
    
    func generateAddress(asset: Asset) -> Observable<ResponseType<ReceiveCryptocurrency.DTO.DisplayInfo>>
    
}
