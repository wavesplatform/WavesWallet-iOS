//
//  ReceiveCardInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/7/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

final class ReceiveCardInteractor: ReceiveCardInteractorProtocol {

    func getInfo(fiatType: ReceiveCard.DTO.FiatType) -> Observable<Responce<ReceiveCard.DTO.Info>> {
        return Observable.empty()
    }
}
