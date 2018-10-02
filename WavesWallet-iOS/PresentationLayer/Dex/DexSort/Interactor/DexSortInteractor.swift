//
//  DexSortInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/3/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

fileprivate enum Constants {
    static let stepSize: Float = 0.000000001
}

final class DexSortInteractor: DexSortInteractorProtocol {
    
    
    func models() -> Observable<[DexSort.DTO.DexSortModel]> {
        
        return Observable.just([])
    }
   
    
    func move(model: DexSort.DTO.DexSortModel, overModel: DexSort.DTO.DexSortModel) {
        
    }
    
    func move(model: DexSort.DTO.DexSortModel, underModel: DexSort.DTO.DexSortModel) {
        
    }
    
    func delete(model: DexSort.DTO.DexSortModel) {
        
    }
    
}
