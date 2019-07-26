//
//  MarketPulseWidgetInteractor.swift
//  MarketPulseWidget
//
//  Created by Pavel Gubin on 24.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import WavesSDK

protocol MarketPulseWidgetInteractorProtocol {
    func pairs() -> Observable<[MarketPulse.DTO.Asset]>
}

final class MarketPulseWidgetInteractor: MarketPulseWidgetInteractorProtocol {
        
    func pairs() -> Observable<[MarketPulse.DTO.Asset]> {
        
        struct Pair {
            let id: String
            let name: String
            let amountAsset: String
            let priceAsset: String
        }
        
        var initPairs: [Pair] = []
        initPairs.append(.init(id: "8LQW8f7P5d5PZM7GtZEBgaqRPGSzS3DfPuiXrURJ4AJS",
                               name: "Bitcoin",
                               amountAsset: "8LQW8f7P5d5PZM7GtZEBgaqRPGSzS3DfPuiXrURJ4AJS",
                               priceAsset: "Ft8X1v1LTa1ABafufpaCWyVj8KkaxUWE6xBhW6sNFJck"))
        
        initPairs.append(.init(id: "474jTeYx2r2Va35794tCScAXWJG9hU2HcgxzMowaZUnu",
                               name: "Ethereum",
                               amountAsset: "474jTeYx2r2Va35794tCScAXWJG9hU2HcgxzMowaZUnu",
                               priceAsset: "WAVES"))

        initPairs.append(.init(id: "BrjUWjndUanm5VsJkbUip8VRYy6LWJePtxya3FNv4TQa",
                               name: "zCash",
                               amountAsset: "BrjUWjndUanm5VsJkbUip8VRYy6LWJePtxya3FNv4TQa",
                               priceAsset: "WAVES"))

        initPairs.append(.init(id: "zMFqXuoyrn5w17PFurTqxB7GsS71fp9dfk6XFwxbPCy",
                               name: "Bitcoin Cash",
                               amountAsset: "zMFqXuoyrn5w17PFurTqxB7GsS71fp9dfk6XFwxbPCy",
                               priceAsset: "WAVES"))
        
        initPairs.append(.init(id: "5WvPKSJXzVE2orvbkJ8wsQmmQKqTv9sGBPksV4adViw3",
                               name: "Monero",
                               amountAsset: "5WvPKSJXzVE2orvbkJ8wsQmmQKqTv9sGBPksV4adViw3",
                               priceAsset: "WAVES"))
        
        initPairs.append(.init(id: "HZk1mbfuJpmxU1Fs4AX5MWLVYtctsNcg6e2C6VKqK8zk",
                               name: "Litecoin",
                               amountAsset: "HZk1mbfuJpmxU1Fs4AX5MWLVYtctsNcg6e2C6VKqK8zk",
                               priceAsset: "WAVES"))
        
        initPairs.append(.init(id: "WAVES", name: "WAVES", amountAsset: "WAVES", priceAsset: MarketPulse.eurAssetId))
        
        
        initPairs.append(.init(id: MarketPulse.eurAssetId, name: "", amountAsset: WavesSDKConstants.wavesAssetId, priceAsset: MarketPulse.eurAssetId))
        initPairs.append(.init(id: MarketPulse.usdAssetId, name: "", amountAsset: WavesSDKConstants.wavesAssetId, priceAsset: MarketPulse.usdAssetId))
        
        return WavesSDK.shared.services
                .dataServices
                .pairsPriceDataService
                .pairsPrice(query: .init(pairs: initPairs.map { model in
                    return DataService.Query.PairsPrice.Pair(amountAssetId: model.amountAsset,
                                                             priceAssetId: model.priceAsset)
                }))
                .map { (models) -> [MarketPulse.DTO.Asset] in
                    
                    var pairs: [MarketPulse.DTO.Asset] = []

                    for (index, model) in models.enumerated() {
                        let pair = initPairs[index]
                        
                        pairs.append(MarketPulse.DTO.Asset(id: pair.id,
                                                           name: pair.name,
                                                           firstPrice: model.firstPrice,
                                                           lastPrice: model.lastPrice,
                                                           volume: model.volume,
                                                           volumeWaves: model.volumeWaves ?? 0))
                    }
                    
                    return pairs
                }

    }
}
