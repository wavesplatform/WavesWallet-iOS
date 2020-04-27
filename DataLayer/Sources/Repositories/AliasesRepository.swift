//
//  AliasRepositoryRemote.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 27/10/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Foundation
import Moya
import RxSwift
import WavesSDK
import WavesSDKExtensions

// TODO: Rename to Services
// TODO: Protocol Split beetwin bd and api

final class AliasesRepository: AliasesRepositoryProtocol {
    private let wavesSDKServices: WavesSDKServices
    
    init(wavesSDKServices: WavesSDKServices) {
        self.wavesSDKServices = wavesSDKServices
    }
    
    func aliases(serverEnvironment: ServerEnvironment,
                 accountAddress: String) -> Observable<[DomainLayer.DTO.Alias]> {
        return wavesSDKServices
            .wavesServices(environment: serverEnvironment)
            .dataServices
            .aliasDataService
            .aliases(address: accountAddress)
            .map { list -> [DomainLayer.DTO.Alias] in
                
                list.map { alias -> DomainLayer.DTO.Alias? in
                    
                    let name = alias.alias
                    let originalName = serverEnvironment.aliasScheme + name
                    return DomainLayer.DTO.Alias(name: name, originalName: originalName)
                }
                .compactMap { $0 }
            }
    }
    
    func alias(serverEnvironment: ServerEnvironment,
               name: String,
               accountAddress: String) -> Observable<String> {
        return wavesSDKServices
            .wavesServices(environment: serverEnvironment)
            .dataServices
            .aliasDataService
            .alias(name: name)
            .map { $0.address }
            .catchError { error -> Observable<String> in
                
                if let error = error as? NetworkError, error == .notFound {
                    return Observable.error(AliasesRepositoryError.dontExist)
                }
                
                return Observable.error(AliasesRepositoryError.invalid)
            }
    }
    
    func saveAliases(accountAddress: String,
                     aliases: [DomainLayer.DTO.Alias]) -> Observable<Bool> {
        assertMethodDontSupported()
        return Observable.never()
    }
}
