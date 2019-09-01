//
//  MobileKeeperRepository.swift
//  DataLayer
//
//  Created by rprokofev on 01.09.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer
import RxSwift

public class MobileKeeperRepository: MobileKeeperRepositoryProtocol {
    
    private var repositoriesFactory: RepositoriesFactoryProtocol
    
    init(repositoriesFactory: RepositoriesFactoryProtocol) {
        self.repositoriesFactory = repositoriesFactory
    }
    
    public func completeRequest(_ request: DomainLayer.DTO.MobileKeeper.CompletingRequest) -> Observable<Bool> {
        
        return Observable.just(false)
    }
    
    public func docodableRequest(_ url: URL, sourceApplication: String) -> Observable<DomainLayer.DTO.MobileKeeper.Request?> {
        
        let request = DomainLayer.DTO.MobileKeeper.Request.init(dApp: .init(name: "Test",
                                                                            iconUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQdF37xBUCZDiNuteNQRfQBTadMGcv25qpDRir40U5ILLYXp7uL",
                                                                            scheme: "waves://"),
                                                                action: .send,
                                                                transaction: .send(.init(recipient: "address",
                                                                                         assetId: "WAVES",
                                                                                         amount: 40000000,
                                                                                         fee: 444,
                                                                                         attachment: "",
                                                                                         feeAssetID: "WAVES")))
      
        
        return Observable.just(request)
    }
}
