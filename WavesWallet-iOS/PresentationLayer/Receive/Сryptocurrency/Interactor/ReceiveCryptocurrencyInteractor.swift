//
//  ReceiveCryptocurrencyInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/5/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

final class ReceiveCryptocurrencyInteractor: ReceiveCryptocurrencyInteractorProtocol {
    
    func generateAddress(asset: DomainLayer.DTO.Asset) -> Observable<Responce<ReceiveCryptocurrency.DTO.DisplayInfo>> {
        
        return Observable.empty()
    }
}
