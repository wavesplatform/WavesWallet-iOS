//
//  DexInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/25/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift
import WavesSDK
import DomainLayer


final class DexListInteractor: DexListInteractorProtocol {
   
    private let dexRealmRepository = UseCasesFactory.instance.repositories.dexRealmRepository
    private let dexListRepository = UseCasesFactory.instance.repositories.dexPairsPriceRepository
    private let auth = UseCasesFactory.instance.authorization
    private let assetsUseCase = UseCasesFactory.instance.assets
    
    func localPairs() -> Observable<DexList.DTO.LocalDisplayInfo> {
        
        return auth.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<DexList.DTO.LocalDisplayInfo> in
            guard let self = self else { return Observable.empty() }
            return self.dexRealmRepository.list(by: wallet.address)
                .flatMap{ [weak self] (pairs) -> Observable<DexList.DTO.LocalDisplayInfo> in
                    guard let self = self else { return Observable.empty() }
                    
                    return self.assetsUseCase.assets(by: pairs.assetsIds, accountAddress: wallet.address)
                        .map { (assets) ->DexList.DTO.LocalDisplayInfo in
                            
                            var smartPairs: [DomainLayer.DTO.Dex.SmartPair] = []
                            
                            for pair in pairs {
                                guard let amountAsset = assets.first(where: {$0.id == pair.amountAssetId}) else { continue }
                                guard  let priceAsset = assets.first(where: {$0.id == pair.priceAssetId}) else { continue }
                                
                                smartPairs.append(.init(id: pair.id,
                                                        amountAsset: amountAsset.dexAsset,
                                                        priceAsset: priceAsset.dexAsset,
                                                        isChecked: pair.isChecked,
                                                        isGeneral: pair.isGeneral,
                                                        sortLevel: pair.sortLevel))
                            }
                            return .init(pairs: smartPairs, authWalletError: false)
                    }
                }
        })
        .catchError({ (error) -> Observable<DexList.DTO.LocalDisplayInfo> in
            return Observable.just(.init(pairs: [], authWalletError: true))
     
        })
    }
    
    func pairs() -> Observable<ResponseType<DexList.DTO.DisplayInfo>> {
        
        return auth.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<ResponseType<DexList.DTO.DisplayInfo>> in
            guard let self = self else { return Observable.empty() }
            
            //TODO: Loading
            return self.dexRealmRepository.list(by: wallet.address)
                .flatMap({ [weak self] (pairs) -> Observable<ResponseType<DexList.DTO.DisplayInfo>> in
                                        
                    
                    guard let self = self else { return Observable.empty() }
                    if pairs.count == 0 {
                        let displayInfo = DexList.DTO.DisplayInfo(pairs: [], authWalletError: false)
                        return Observable.just(ResponseType(output: displayInfo, error: nil))
                    } else {
                        
                        return self.assetsUseCase.assets(by: pairs.assetsIds, accountAddress: wallet.address)
                            .flatMap {[weak self] (assets) -> Observable<ResponseType<DexList.DTO.DisplayInfo>> in
                                guard let self = self else { return Observable.empty() }
                                
                                let simplePairs =  pairs.map{ DomainLayer.DTO.Dex.SimplePair(amountAsset: $0.amountAssetId,
                                                                                             priceAsset: $0.priceAssetId) }
                                return self.dexListRepository.pairs(accountAddress: wallet.address,
                                                                   pairs: simplePairs)
                                    .map { (list) -> ResponseType<DexList.DTO.DisplayInfo> in
                                        var listPairs: [DexList.DTO.Pair] = []
                                                                       
                                        for (index, pair) in list.enumerated() {
                                            let localPair = pairs[index]
                                            
                                            let pair = DexList.DTO.Pair(id: localPair.id,
                                                                        firstPrice: pair.firstPrice,
                                                                        lastPrice: pair.lastPrice,
                                                                        amountAsset: pair.amountAsset,
                                                                        priceAsset: pair.priceAsset,
                                                                        isGeneral: localPair.isGeneral,
                                                                        sortLevel: localPair.sortLevel)
                                            listPairs.append(pair)
                                           
                                        }
                                        let displayInfo = DexList.DTO.DisplayInfo(pairs: listPairs, authWalletError: false)
                                        return ResponseType(output: displayInfo, error: nil)
                                        
                                }
                                .catchError{ (error) -> Observable<ResponseType<DexList.DTO.DisplayInfo>> in
                                    if let error = error as? NetworkError {
                                        return Observable.just(ResponseType(output: nil, error: error))
                                    }
                                    return Observable.just(ResponseType(output: nil, error: NetworkError.error(by: error)))
                                }
                        }
                    }
            })
        })
        .catchError({ (error) -> Observable<ResponseType<DexList.DTO.DisplayInfo>> in
            let displayInfo = DexList.DTO.DisplayInfo(pairs: [], authWalletError: true)
            return Observable.just(ResponseType(output: displayInfo, error: nil))
        })
    }
}
