//
//  AccountsInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 10.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol AccountsInteractorProtocol {
    func accounts(by ids: [String], accountAddress: String) -> Observable<[DomainLayer.DTO.Account]>
    func accountsSync(by ids: [String], accountAddress: String) -> SyncObservable<[DomainLayer.DTO.Account]>
}

final class AccountsInteractor: AccountsInteractorProtocol {

    private let addressBookRepository: AddressBookRepositoryProtocol
    private let aliasesInteractor: AliasesInteractorProtocol

    init(addressBookRepository: AddressBookRepositoryProtocol,
         aliasesInteractor: AliasesInteractorProtocol) {

        self.addressBookRepository = addressBookRepository
        self.aliasesInteractor = aliasesInteractor
    }

    func accountsSync(by ids: [String], accountAddress: String) -> SyncObservable<[DomainLayer.DTO.Account]> {
        return aliasesInteractor
            .aliases(by: accountAddress)
            .flatMapLatest { [weak self] (sync) -> SyncObservable<[DomainLayer.DTO.Account]> in

                guard let owner = self else { return Observable.never() }

                if let remote = sync.remote {

                    return owner
                        .localAccounts(myAliases: remote, ids: ids, accountAddress: accountAddress)
                        .map({ accounts -> Sync<[DomainLayer.DTO.Account]> in
                            return .remote(accounts)
                        })
                        .catchError({ (localError) -> SyncObservable<[DomainLayer.DTO.Account]> in
                            return .error(localError)
                        })

                } else if let local = sync.local {

                    return owner
                        .localAccounts(myAliases: local.result, ids: ids, accountAddress: accountAddress)
                        .map({ accounts -> Sync<[DomainLayer.DTO.Account]> in
                            return .local(accounts, error: local.error)
                        })
                        .catchError({ (localError) -> SyncObservable<[DomainLayer.DTO.Account]> in
                            return .error(local.error)
                        })
                } else if let error = sync.error {
                    return SyncObservable.just(.error(error))
                }
                return Observable.never()
            }
            .share()
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global(qos: .background)))
    }

    private func localAccounts(myAliases: [DomainLayer.DTO.Alias], ids: [String], accountAddress: String) -> Observable<[DomainLayer.DTO.Account]> {

        return Observable.merge(addressBookRepository.listListener(by: accountAddress),
                                addressBookRepository.list(by: accountAddress))
            .flatMap({ (contacts) -> Observable<[DomainLayer.DTO.Account]> in

                let maps = contacts.reduce(into: [String : DomainLayer.DTO.Contact](), { (result, contact) in
                    result[contact.address] = contact
                })

                let accounts = ids.map({ address -> DomainLayer.DTO.Account in

                    let isMyAccount = accountAddress == address || myAliases.map { $0.name }.contains(address)
                    return DomainLayer.DTO.Account(address: address,
                                                   contact: maps[address],
                                                   isMyAccount: isMyAccount,
                                                   aliases: isMyAccount == true ? myAliases : [])
                })

                return Observable.just(accounts)
            })
    }

    func accounts(by ids: [String], accountAddress: String) -> Observable<[DomainLayer.DTO.Account]> {

        return self.accountsSync(by: ids, accountAddress: accountAddress)
            .flatMap({ (sync) -> Observable<[DomainLayer.DTO.Account]> in

                if let remote = sync.resultIngoreError {
                    return Observable.just(remote)
                }

                switch sync {
                case .remote(let model):
                    return Observable.just(model)

                case .local(_, let error):
                    return Observable.error(error)

                case .error(let error):
                    return Observable.error(error)
                }
            })
    }
}
