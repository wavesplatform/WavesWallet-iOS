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

private enum Constants {
    static var notFoundCode = 404
}

final class AliasesRepository: AliasesRepositoryProtocol {

    private let environmentRepository: EnvironmentRepositoryProtocol
    private let aliasNode: MoyaProvider<Node.Service.Alias> = .nodeMoyaProvider()

    init(environmentRepository: EnvironmentRepositoryProtocol) {
        self.environmentRepository = environmentRepository
    }

    func aliases(accountAddress: String) -> Observable<[DomainLayer.DTO.Alias]> {

        return environmentRepository
            .accountEnvironment(accountAddress: accountAddress)
            .flatMap({ [weak self] environment -> Observable<(aliases: [String], environment: Environment)> in
                guard let owner = self else { return Observable.never() }
                return owner
                    .aliasNode
                    .rx
                    .request(Node.Service.Alias(environment: environment,
                                                kind: .list(accountAddress: accountAddress)),
                            callbackQueue: DispatchQueue.global(qos: .background))
                    .filterSuccessfulStatusAndRedirectCodes()
                    .asObservable()
                    .catchError({ (error) -> Observable<Response> in
                        return Observable.error(NetworkError.error(by: error))
                    })
                    .map([String].self)
                    .map { (aliases: $0, environment: environment) }
            })
            .map({ data -> [DomainLayer.DTO.Alias] in

                let list = data.aliases
                let aliasScheme = data.environment.aliasScheme

                return list.map({ originalName -> DomainLayer.DTO.Alias? in

                    if originalName.range(of: aliasScheme) != nil {
                        let name = originalName.replacingOccurrences(of: aliasScheme, with: "")
                        return DomainLayer.DTO.Alias(name: name, originalName: originalName)
                    }

                    return nil
                })
                .compactMap { $0 }
            })
    }

    func alias(by name: String, accountAddress: String) -> Observable<String> {

        return environmentRepository
            .accountEnvironment(accountAddress: accountAddress)
            .flatMap({ [weak self] environment -> Observable<String> in
                guard let owner = self else { return Observable.never() }
                return owner
                    .aliasNode
                    .rx
                    .request(Node.Service.Alias(environment: environment,
                                                kind: .alias(name: name)),
                            callbackQueue: DispatchQueue.global(qos: .background))
                    .filterSuccessfulStatusAndRedirectCodes()
                    .map([String:String].self)
                    .map({ $0["address"] ?? "" })
                    .asObservable()
                    .catchError({ e -> Observable<String> in
                        guard let error = e as? MoyaError else {
                            return Observable.error(NetworkError.error(by: e))
                        }
                        guard let response = error.response else { return Observable.error(NetworkError.error(by: e)) }
                        guard response.statusCode == Constants.notFoundCode else { return Observable.error(NetworkError.error(by: e)) }
                        return Observable.error(AliasesRepositoryError.dontExist)                    
                    })

            })
    }
}
