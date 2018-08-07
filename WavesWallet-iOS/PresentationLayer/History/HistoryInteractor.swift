//
//  HistoryInteractor.swift
//  WavesWallet-iOS
//
//  Created by Mac on 03/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol HistoryInteractorProtocol {
    func all() -> AsyncObservable<[HistoryTypes.DTO.Transaction]>
}

final class HistoryInteractorMock: HistoryInteractorProtocol {
    
    func all() -> Observable<[HistoryTypes.DTO.Transaction]> {
        let asset = HistoryTypes.DTO.Transaction(id: "1", name: "Ssd", balance: Money(100, 1), kind: .transfer, tag: "Waves", sortLevel: 0)
        return Observable.just([asset, asset, asset])
    }
    
}
