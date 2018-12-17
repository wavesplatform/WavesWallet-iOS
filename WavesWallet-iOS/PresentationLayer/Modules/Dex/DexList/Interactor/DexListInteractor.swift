//
//  DexInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/25/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

private enum Constants {
    static let pair = "/v0" + "/pairs"
}

final class DexListInteractor: DexListInteractorProtocol {
   
    private let dexRealmRepository = FactoryRepositories.instance.dexRealmRepository
    private let dexListRepository = FactoryRepositories.instance.dexListRepository
    private let auth = FactoryInteractors.instance.authorization
    
    func pairs() -> Observable<ResponseType<[DexList.DTO.Pair]>> {
        
        return auth.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<ResponseType<[DexList.DTO.Pair]>> in
            guard let owner = self else { return Observable.empty() }
            
            return owner.dexRealmRepository.list(by: wallet.address)
                .flatMap({ [weak self] (pairs) -> Observable<ResponseType<[DexList.DTO.Pair]>> in
                                        
                    guard let owner = self else { return Observable.empty() }
                    if pairs.count == 0 {
                        return Observable.just(ResponseType(output: [], error: nil))
                    }
                    else {
                        return owner.dexListRepository.list(by: pairs).flatMap({ (pairs) -> Observable<ResponseType<[DexList.DTO.Pair]>> in
                            return Observable.just(ResponseType(output: pairs, error: nil))
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
    }
}
