//
//  AliasesInteractor.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 24/11/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

import Foundation
import RxSwift
import RxCocoa

protocol AliasesInteractorProtocol {
    func aliases(by accountAddress: String) -> SyncObservable<[DomainLayer.DTO.Alias]>
}

final class AliasesInteractor: AliasesInteractorProtocol {

    private let aliasesRepository: AliasesRepositoryProtocol
    private let aliasesRepositoryLocal: AliasesRepositoryProtocol

    init(aliasesRepositoryRemote: AliasesRepositoryProtocol,
         aliasesRepositoryLocal: AliasesRepositoryProtocol) {
        self.aliasesRepository = aliasesRepositoryRemote
        self.aliasesRepositoryLocal = aliasesRepositoryLocal
    }

    func aliases(by accountAddress: String) -> SyncObservable<[DomainLayer.DTO.Alias]> {

        return remoteAliases(by: accountAddress)
            .map({ aliases in
                return .remote(aliases)
            })
            .catchError { [weak self] remoteError -> SyncObservable<[DomainLayer.DTO.Alias]> in

                guard let owner = self else { return Observable.never() }

                return owner
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
        return aliasesRepository
            .aliases(accountAddress: accountAddress)
            .flatMapLatest({ [weak self] aliases -> Observable<[DomainLayer.DTO.Alias]> in
                guard let owner = self else { return Observable.never() }
                return owner
                    .aliasesRepositoryLocal
                    .saveAliases(by: accountAddress, aliases: aliases)
                    .map({ _ -> [DomainLayer.DTO.Alias] in
                        return aliases
                    })
            })
    }

    private func localeAliases(by accountAddress: String) -> Observable<[DomainLayer.DTO.Alias]> {
        return aliasesRepositoryLocal.aliases(accountAddress: accountAddress)
    }
}

