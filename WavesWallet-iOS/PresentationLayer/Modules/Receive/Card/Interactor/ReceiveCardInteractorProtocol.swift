//
//  ReceiveCardInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/7/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol ReceiveCardInteractorProtocol {
    
    func getInfo(fiatType: ReceiveCard.DTO.FiatType) -> Observable<ResponseType<ReceiveCard.DTO.Info>>
    func getWavesAmount(fiatAmount: Money, fiatType: ReceiveCard.DTO.FiatType) -> Observable<ResponseType<Money>>
}
