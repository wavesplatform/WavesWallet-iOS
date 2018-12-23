//
//  DexListRepositoryRemote.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/17/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

private enum Constants {
    static let pairsPath = "/v0" + "/pairs"
}

final class DexListRepositoryRemote: DexListRepositoryProtocol {
    
    func list(by pairs: [DexMarket.DTO.Pair]) -> Observable<[DexList.DTO.Pair]> {
     
        return Observable.create({ (subscribe) -> Disposable in
            
            var url = Environments.current.servers.dataUrl.relativeString + Constants.pairsPath

            for pair in pairs {
                if (url as NSString).range(of: "?").location == NSNotFound {
                    url.append("?")
                }
                if url.last != "?" {
                    url.append("&")
                }
                url.append("pairs=" + pair.amountAsset.id + "/" + pair.priceAsset.id)
            }
            
            let req = NetworkManager.getRequestWithUrl(url, parameters: nil) { (info, error) in
                
                if let error = error {
                    subscribe.onError(error)
                }
                else if let info = info {
            
                    var listPairs: [DexList.DTO.Pair] = []
                    
                    for (index, item) in info["data"].arrayValue.enumerated() {
                        
                        let localPair = pairs[index]
                        
                        let amountAsset = Dex.DTO.Asset(id: localPair.amountAsset.id,
                                                        name: localPair.amountAsset.name,
                                                        shortName: localPair.amountAsset.shortName,
                                                        decimals: localPair.amountAsset.decimals)
                        
                        let priceAsset = Dex.DTO.Asset(id: localPair.priceAsset.id,
                                                       name: localPair.priceAsset.name,
                                                       shortName: localPair.priceAsset.shortName,
                                                       decimals: localPair.priceAsset.decimals)
                        
                        let info = item["data"]
                        let firstPrice = Money(value: Decimal(info["firstPrice"].doubleValue), priceAsset.decimals)
                        let lastPrice = Money(value: Decimal(info["lastPrice"].doubleValue), priceAsset.decimals)
                        
                        let pair = DexList.DTO.Pair(firstPrice: firstPrice,
                                                    lastPrice: lastPrice,
                                                    amountAsset: amountAsset,
                                                    priceAsset: priceAsset,
                                                    isGeneral: localPair.isGeneral,
                                                    sortLevel: localPair.sortLevel)
                        listPairs.append(pair)
                    }
                    
                    subscribe.onNext(listPairs)
                    subscribe.onCompleted()
                }
            }
            
            return Disposables.create {
                req.cancel()
            }
        })
        
    }
}
