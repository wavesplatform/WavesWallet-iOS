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
    func all() -> AsyncObservable<[HistoryTypes.DTO.Asset]>
}

final class HistoryInteractorMock: HistoryInteractorProtocol {
    
    func all() -> Observable<[HistoryTypes.DTO.Asset]> {
        let asset = HistoryTypes.DTO.Asset(id: "1", name: "Имя")
        return Observable.just([asset, asset, asset])
    }
    
}
