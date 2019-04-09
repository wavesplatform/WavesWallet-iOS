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

private enum Constants {
    static var notFoundCode = 404
}

final class AliasesRepository: AliasesRepositoryProtocol {
    
    private let environmentRepository: EnvironmentRepositoryProtocol
    private let aliasApi: MoyaProvider<API.Service.Alias> = .nodeMoyaProvider()
    
    init(environmentRepository: EnvironmentRepositoryProtocol) {
        self.environmentRepository = environmentRepository
    }

    func aliases(accountAddress: String) -> Observable<[DomainLayer.DTO.Alias]> {

        return environmentRepository
            .accountEnvironment(accountAddress: accountAddress)
            .flatMap({ [weak self] environment -> Observable<(aliases: [API.DTO.Alias], environment: Environment)> in
                guard let self = self else { return Observable.never() }
                return self
                    .aliasApi
                    .rx
                    .request(API.Service.Alias(environment: environment,
                                                kind: .list(accountAddress: accountAddress)),
                            callbackQueue: DispatchQueue.global(qos: .userInteractive))
                    .filterSuccessfulStatusAndRedirectCodes()
                    .asObservable()
                    .catchError({ (error) -> Observable<Response> in
                        return Observable.error(NetworkError.error(by: error))
                    })
                    .map(API.Response<[API.Response<API.DTO.Alias>]>.self)
                    .map { (aliases: $0.data.map{ $0.data }, environment: environment) }
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
        return environmentRepository.accountEnvironment(accountAddress: accountAddress)
            .flatMap({ [weak self] (environment) -> Observable<String> in
                guard let self = self else { return Observable.empty() }
                return self.aliasApi.rx.request(API.Service.Alias(environment: environment,
                                                                   kind: .alias(name: name)))
                .filterSuccessfulStatusAndRedirectCodes()
                .map(API.Response<API.DTO.Alias>.self)
                .map({ (response) -> String in
                    return response.data.address
                })
                .asObservable()
                .catchError({ (e) -> Observable<String> in
                    guard let error = e as? MoyaError else {
                        return Observable.error(NetworkError.error(by: e))
                    }
                    guard let response = error.response else { return Observable.error(NetworkError.error(by: e)) }
                    guard response.statusCode == Constants.notFoundCode else { return Observable.error(NetworkError.error(by: e)) }
                    return Observable.error(AliasesRepositoryError.dontExist)
                })
            })
    }

    func saveAliases(by accountAddress: String, aliases: [DomainLayer.DTO.Alias]) -> Observable<Bool> {
        assertMethodDontSupported()
        return Observable.never()
    }
}
