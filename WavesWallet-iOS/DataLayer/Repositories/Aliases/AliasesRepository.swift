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
import WavesSDKClientCrypto
import WavesSDKServices

final class AliasesRepository: AliasesRepositoryProtocol {
    
    private let environmentRepository: EnvironmentRepositoryProtocol
    private let aliasDataService = ServicesFactory.shared.aliasDataService
    
    init(environmentRepository: EnvironmentRepositoryProtocol) {
        self.environmentRepository = environmentRepository
    }

    func aliases(accountAddress: String) -> Observable<[DomainLayer.DTO.Alias]> {

        return environmentRepository
            .accountEnvironment(accountAddress: accountAddress)
            .flatMap({ [weak self] environment -> Observable<(aliases: [DataService.DTO.Alias], environment: Environment)> in
                guard let self = self else { return Observable.never() }

                return self
                    .aliasDataService
                    .list(address: accountAddress,
                          enviroment: environment.environmentServiceData)
                    .map { (aliases: $0, environment: environment) }
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
        return environmentRepository
            .accountEnvironment(accountAddress: accountAddress)
            .flatMap({ [weak self] (environment) -> Observable<String> in
                
                guard let self = self else { return Observable.empty() }
                
                
                return self
                    .aliasDataService
                    .alias(name: name,
                           enviroment: environment.environmentServiceData)
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
