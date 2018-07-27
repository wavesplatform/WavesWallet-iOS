//
//  DexInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/25/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

protocol DexInteractorProtocol {
    func dexPairs() -> AsyncObservable<[DexTypes.DTO.DexListModel]>
}

final class DexInteractor: DexInteractorProtocol {
   
    func dexPairs() -> AsyncObservable<[DexTypes.DTO.DexListModel]> {
        return AsyncObservable.just([])
    }
}

final class DexInteractorMock: DexInteractorProtocol {
   
    func dexPairs() -> AsyncObservable<[DexTypes.DTO.DexListModel]> {
        
        return AsyncObservable.just([
            
                DexTypes.DTO.DexListModel(percent: 30.2, amountAsset: "xxx", amountAssetName: "Waves", priceAsset: "xxx", priceAssetName: "Btc", amountDecimals: 8, priceDecimals: 8),
               
                DexTypes.DTO.DexListModel(percent: -20.2, amountAsset: "xxx", amountAssetName: "Eth", priceAsset: "xxx", priceAssetName: "Waves", amountDecimals: 8, priceDecimals: 8),
                
                DexTypes.DTO.DexListModel(percent: 40.2, amountAsset: "xxx", amountAssetName: "Eth", priceAsset: "xxx", priceAssetName: "Eth Classic", amountDecimals: 8, priceDecimals: 8),
                
                DexTypes.DTO.DexListModel(percent: -10.2, amountAsset: "xxx", amountAssetName: "Bitcoin", priceAsset: "xxx", priceAssetName: "zCash", amountDecimals: 8, priceDecimals: 8),
                
                DexTypes.DTO.DexListModel(percent: 80.2, amountAsset: "xxx", amountAssetName: "EOS", priceAsset: "xxx", priceAssetName: "Monero", amountDecimals: 8, priceDecimals: 8)])
    }
}

