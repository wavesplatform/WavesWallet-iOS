//
//  AddressRepositoryRemote.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 21/01/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import WavesSDK

final class AddressRepositoryRemote: AddressRepositoryProtocol {

    private let applicationEnviroment: Observable<ApplicationEnviroment>
    
    init(applicationEnviroment: Observable<ApplicationEnviroment>) {
        self.applicationEnviroment = applicationEnviroment
    }
    
    func isSmartAddress(accountAddress: String) -> Observable<Bool> {
        
        return applicationEnviroment.flatMapLatest({ [weak self] (applicationEnviroment) -> Observable<Bool> in
                
                guard let self = self else { return Observable.never() }
                
                return applicationEnviroment
                    .services
                    .nodeServices
                    .addressesNodeService
                    .scriptInfo(address: accountAddress)
                    .map { ($0.extraFee ?? 0) > 0 }
            })
    }
}
