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
    
    func pairs() -> Observable<ResponseType<DexList.DTO.DisplayInfo>> {
        
        return auth.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<ResponseType<DexList.DTO.DisplayInfo>> in
            guard let self = self else { return Observable.empty() }
            
            return self.dexRealmRepository.list(by: wallet.address)
                .flatMap({ [weak self] (pairs) -> Observable<ResponseType<DexList.DTO.DisplayInfo>> in
                                        
                    guard let self = self else { return Observable.empty() }
                    if pairs.count == 0 {
                        let displayInfo = DexList.DTO.DisplayInfo(pairs: [], authWalletError: false)
                        return Observable.just(ResponseType(output: displayInfo, error: nil))
                    } else {

                        let listPairs = pairs.map { DomainLayer.DTO.Dex.Pair(amountAsset: $0.amountAsset,
                                                                             priceAsset: $0.priceAsset)}
                        //TODO: Move code to other method
                        return self.dexListRepository.list(by: wallet.address, pairs: listPairs)
                            .flatMap({ (list) -> Observable<ResponseType<DexList.DTO.DisplayInfo>> in
                                
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
                                let displayInfo = DexList.DTO.DisplayInfo(pairs: listPairs, authWalletError: false)
                                return Observable.just(ResponseType(output: displayInfo, error: nil))
                            })
                        .catchError({ (error) -> Observable<ResponseType<DexList.DTO.DisplayInfo>> in
                            if let error = error as? NetworkError {
                                return Observable.just(ResponseType(output: nil, error: error))
                            }
                            return Observable.just(ResponseType(output: nil, error: NetworkError.error(by: error)))
                        })
                    }
            })
        })
        .catchError({ (error) -> Observable<ResponseType<DexList.DTO.DisplayInfo>> in
            let displayInfo = DexList.DTO.DisplayInfo(pairs: [], authWalletError: true)
            return Observable.just(ResponseType(output: displayInfo, error: nil))
        })
    }
}
