//
//  DexInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/25/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift


final class DexListInteractor: DexListInteractorProtocol {
   
    private let dexRealmRepository = FactoryRepositories.instance.dexRealmRepository
    private let dexListRepository = FactoryRepositories.instance.dexPairsPriceRepository
    private let auth = FactoryInteractors.instance.authorization
    
    func pairs() -> Observable<ResponseType<[DexList.DTO.Pair]>> {
        
        return auth.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<ResponseType<[DexList.DTO.Pair]>> in
            guard let self = self else { return Observable.empty() }
            
            return self.dexRealmRepository.list(by: wallet.address)
                .flatMap({ [weak self] (pairs) -> Observable<ResponseType<[DexList.DTO.Pair]>> in
                                        
                    guard let self = self else { return Observable.empty() }
                    if pairs.count == 0 {
                        return Observable.just(ResponseType(output: [], error: nil))
                    } else {

                        let listPairs = pairs.map { DomainLayer.DTO.Dex.Pair(amountAsset: $0.amountAsset,
                                                                             priceAsset: $0.priceAsset)}
                        //TODO: Move code to other method
                        return self.dexListRepository.list(by: wallet.address, pairs: listPairs)
                            .flatMap({ (list) -> Observable<ResponseType<[DexList.DTO.Pair]>> in
                                
                                var listPairs: [DexList.DTO.Pair] = []
                                
                                for (index, pair) in list.enumerated() {
                                    let localPair = pairs[index]
                                    
                                    let pair = DexList.DTO.Pair(firstPrice: pair.firstPrice,
                                                                lastPrice: pair.lastPrice,
                                                                amountAsset: pair.amountAsset,
                                                                priceAsset: pair.priceAsset,
                                                                isGeneral: localPair.isGeneral,
                                                                sortLevel: localPair.sortLevel)
                                    listPairs.append(pair)
                                    
                                }
                                return Observable.just(ResponseType(output: listPairs, error: nil))
                            })
                        .catchError({ (error) -> Observable<ResponseType<[DexList.DTO.Pair]>> in
                            if let error = error as? NetworkError {
                                return Observable.just(ResponseType(output: nil, error: error))
                            }
                            return Observable.just(ResponseType(output: nil, error: NetworkError.error(by: error)))
                        })
                    }
            })
        })
        .catchError({ (error) -> Observable<ResponseType<[DexList.DTO.Pair]>> in
            return Observable.just(ResponseType(output: nil, error: NetworkError.authWallet))
        })
    }
}
