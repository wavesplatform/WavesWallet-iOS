//
//  DexMyOrdersInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/24/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift
import DomainLayer

final class DexMyOrdersInteractor: DexMyOrdersInteractorProtocol {
    
    private let auth = UseCasesFactory.instance.authorization
    private let repository = UseCasesFactory.instance.repositories.dexOrderBookRepository
    private let serverEnvironmentUseCase = UseCasesFactory.instance.serverEnvironmentUseCase
    
    var pair: DexTraderContainer.DTO.Pair!
    
    func myOrders() -> Observable<[DomainLayer.DTO.Dex.MyOrder]> {
        
        let wallet = auth.authorizedWallet()
        let serverEnviroment = serverEnvironmentUseCase.serverEnviroment()
        
        return Observable.zip(wallet, serverEnviroment)
            .flatMap({ [weak self] wallet, serverEnviroment -> Observable<[DomainLayer.DTO.Dex.MyOrder]>  in
                
                guard let self = self else { return Observable.empty() }
                
                return self.repository.myOrders(serverEnvironment: serverEnviroment,
                                                wallet: wallet,
                                                amountAsset: self.pair.amountAsset,
                                                priceAsset: self.pair.priceAsset)
                    .catchError({ (error) -> Observable<[DomainLayer.DTO.Dex.MyOrder]> in
                        return Observable.just([])
                    })
            })
    }
    
}
