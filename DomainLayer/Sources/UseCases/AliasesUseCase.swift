//
//  AliasesInteractor.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 24/11/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Extensions

final class AliasesUseCase: AliasesUseCaseProtocol {
    
    private let serverEnvironmentUseCase: ServerEnvironmentUseCase
    private let aliasesRepository: AliasesRepositoryProtocol
    private let aliasesRepositoryLocal: AliasesRepositoryProtocol
    
    init(aliasesRepositoryRemote: AliasesRepositoryProtocol,
         aliasesRepositoryLocal: AliasesRepositoryProtocol,
         serverEnvironmentUseCase: ServerEnvironmentUseCase) {
        self.aliasesRepository = aliasesRepositoryRemote
        self.aliasesRepositoryLocal = aliasesRepositoryLocal
        self.serverEnvironmentUseCase = serverEnvironmentUseCase
    }
    
    func aliases(by accountAddress: String) -> SyncObservable<[DomainLayer.DTO.Alias]> {
        
        return remoteAliases(by: accountAddress)
            .map({ aliases in
                return .remote(aliases)
            })
            .catchError { [weak self] remoteError -> SyncObservable<[DomainLayer.DTO.Alias]> in
                
                guard let self = self else { return Observable.never() }
                
                return self
                    .localeAliases(by: accountAddress)
                    .map({ aliases in
                        if aliases.count > 0 {
                            return .local(aliases, error: remoteError)
                        } else {
                            return .error(remoteError)
                        }
                    })
                    .catchError({ (localError) -> SyncObservable<[DomainLayer.DTO.Alias]> in
                        return SyncObservable<[DomainLayer.DTO.Alias]>.just(.error(remoteError))
                    })
        }
        .share()
        .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global(qos: .userInteractive)))
    }
    
    private func remoteAliases(by accountAddress: String) -> Observable<[DomainLayer.DTO.Alias]> {
        
        return serverEnvironmentUseCase
            .serverEnviroment()
            .flatMap { [weak self] serverEnvironment -> Observable<[DomainLayer.DTO.Alias]> in
                
                guard let self = self else { return Observable.never() }
                
                return self.aliasesRepository
                    .aliases(serverEnvironment: serverEnvironment,
                             accountAddress: accountAddress)
                    .flatMapLatest({ [weak self] aliases -> Observable<[DomainLayer.DTO.Alias]> in
                        guard let self = self else { return Observable.never() }
                        return self
                            .aliasesRepositoryLocal
                            .saveAliases(accountAddress: accountAddress,
                                         aliases: aliases)
                            .map({ _ -> [DomainLayer.DTO.Alias] in
                                return aliases
                            })
                    })
        }
    }
    
    private func localeAliases(by accountAddress: String) -> Observable<[DomainLayer.DTO.Alias]> {
        
        return serverEnvironmentUseCase
            .serverEnviroment()
            .flatMap { [weak self] serverEnvironment -> Observable<[DomainLayer.DTO.Alias]> in
                
                guard let self = self else { return Observable.never() }
                return self.aliasesRepositoryLocal
                    .aliases(serverEnvironment: serverEnvironment,
                             accountAddress: accountAddress)
        }
    }
}

