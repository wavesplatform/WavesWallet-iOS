//
//  DexSortInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/3/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol DexSortInteractorProtocol {
    
    func models() -> Observable<[DexSort.DTO.DexSortModel]>
    
    func move(asset: DexSort.DTO.DexSortModel, underAsset: WalletSort.DTO.Asset)
    func move(asset: DexSort.DTO.DexSortModel, overAsset: WalletSort.DTO.Asset)
    
    func update(asset: DexSort.DTO.DexSortModel)
}

final class DexSortInteractor: DexSortInteractorProtocol {
    
    func models() -> Observable<[DexSort.DTO.DexSortModel]> {
        
        return Observable.just([DexSort.DTO.DexSortModel.init(id: "1", name: "Waves / Btc", sortLevel: 0)])
    }
    
    func move(asset: DexSort.DTO.DexSortModel, overAsset: WalletSort.DTO.Asset) {
        
    }
    
    func move(asset: DexSort.DTO.DexSortModel, underAsset: WalletSort.DTO.Asset) {
        
    }
    
    func update(asset: DexSort.DTO.DexSortModel) {
        
    }
}
