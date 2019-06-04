//
//  AliasRepositoryRemote.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 27/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import WavesSDKExtension

import WavesSDK

final class AliasesRepository: AliasesRepositoryProtocol {
            
    private let applicationEnviroment: Observable<ApplicationEnviroment>
    
    init(applicationEnviroment: Observable<ApplicationEnviroment>) {
        self.applicationEnviroment = applicationEnviroment
    }

    func aliases(accountAddress: String) -> Observable<[DomainLayer.DTO.Alias]> {

        return applicationEnviroment.flatMapLatest({ [weak self] (applicationEnviroment) -> Observable<(aliases: [DataService.DTO.Alias], environment: WalletEnvironment)> in
            
            guard let self = self else { return Observable.never() }

            return applicationEnviroment
                .services
                .dataServices
                .aliasDataService
                .list(address: accountAddress)
                .map { (aliases: $0, environment: applicationEnviroment.walletEnviroment) }
        })
        .map({ data -> [DomainLayer.DTO.Alias] in

            let list = data.aliases
            let aliasScheme = data.environment.aliasScheme
            
            return list.map({ alias -> DomainLayer.DTO.Alias? in

                let name = alias.alias
                let originalName = aliasScheme + name
                return DomainLayer.DTO.Alias(name: name, originalName: originalName)
            })
            .compactMap { $0 }
        })
    }

    func alias(by name: String, accountAddress: String) -> Observable<String> {
        return applicationEnviroment.flatMapLatest({ [weak self] (applicationEnviroment) -> Observable<String> in
            
                guard let self = self else { return Observable.empty() }
                
                return applicationEnviroment
                    .services
                    .dataServices
                    .aliasDataService
                    .alias(name: name)
                    .map { $0.address }
                    .catchError({ (error) -> Observable<String> in
                        
                        if let error = error as? NetworkError, error == .notFound {
                            return Observable.error(AliasesRepositoryError.dontExist)
                        }
                        
                        return Observable.error(AliasesRepositoryError.invalid)
                    })
            })
    }

    func saveAliases(by accountAddress: String, aliases: [DomainLayer.DTO.Alias]) -> Observable<Bool> {
        assertMethodDontSupported()
        return Observable.never()
    }
}
