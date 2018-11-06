//
//  DexSortInteractorMock.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/7/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

fileprivate enum Constants {
    static let stepSize: Float = 0.000000001
}

final class DexSortInteractorMock: DexSortInteractorProtocol {

    private static var testModels: [DexSort.DTO.DexSortModel] =
        
        [DexSort.DTO.DexSortModel(id: "1", name: "Waves / BTC", sortLevel: 0),
         DexSort.DTO.DexSortModel(id: "2", name: "ETH / BTC", sortLevel: 0),
         DexSort.DTO.DexSortModel(id: "3", name: "BTC / BTC Cash", sortLevel: 0),
         DexSort.DTO.DexSortModel(id: "4", name: "ETH Classic / Monero", sortLevel: 0),
         DexSort.DTO.DexSortModel(id: "5", name: "Monero / ZCash", sortLevel: 0),
         DexSort.DTO.DexSortModel(id: "6", name: "BTC / Monero", sortLevel: 0),
         DexSort.DTO.DexSortModel(id: "7", name: "Waves / EOS", sortLevel: 0),
         DexSort.DTO.DexSortModel(id: "8", name: "IOTA / Tether", sortLevel: 0),
         DexSort.DTO.DexSortModel(id: "9", name: "TRON / NEO", sortLevel: 0),
         DexSort.DTO.DexSortModel(id: "10", name: "Tezos / Stellar", sortLevel: 0),
         DexSort.DTO.DexSortModel(id: "11", name: "XRP / BTC", sortLevel: 0)]
    
    
    func models() -> Observable<[DexSort.DTO.DexSortModel]> {
        
        return Observable.create({ (subscribe) -> Disposable in
            subscribe.onNext(DexSortInteractorMock.testModels)
            return Disposables.create()
        })
    }
    
    
    func move(model: DexSort.DTO.DexSortModel, overModel: DexSort.DTO.DexSortModel) {
        
    }
    
    func move(model: DexSort.DTO.DexSortModel, underModel: DexSort.DTO.DexSortModel) {
        
    }
    
    func delete(model: DexSort.DTO.DexSortModel) {
        
        if let index = DexSortInteractorMock.testModels.index(where: {$0.id == model.id}) {
            DexSortInteractorMock.testModels.remove(at: index)
        }
    }
}
