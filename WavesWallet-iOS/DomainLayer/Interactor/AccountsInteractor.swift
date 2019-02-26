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

protocol AddressInteractorProtocol {
    func address(by ids: [String], myAddress: String) -> Observable<[DomainLayer.DTO.Address]>
    func addressSync(by ids: [String], myAddress: String) -> SyncObservable<[DomainLayer.DTO.Address]>
}

final class AddressInteractor: AddressInteractorProtocol {

    private let addressBookRepository: AddressBookRepositoryProtocol
    private let aliasesInteractor: AliasesInteractorProtocol

    init(addressBookRepository: AddressBookRepositoryProtocol,
         aliasesInteractor: AliasesInteractorProtocol) {

        self.addressBookRepository = addressBookRepository
        self.aliasesInteractor = aliasesInteractor
    }

    func addressSync(by ids: [String], myAddress: String) -> SyncObservable<[DomainLayer.DTO.Address]> {
        return aliasesInteractor
            .aliases(by: myAddress)
            .flatMapLatest { [weak self] (sync) -> SyncObservable<[DomainLayer.DTO.Address]> in

                guard let owner = self else { return Observable.never() }

                if let remote = sync.remote {

                    return owner
                        .localAddress(myAliases: remote, ids: ids, accountAddress: myAddress)
                        .map({ accounts -> Sync<[DomainLayer.DTO.Address]> in
                            return .remote(accounts)
                        })
                        .catchError({ (localError) -> SyncObservable<[DomainLayer.DTO.Address]> in
                            return .error(localError)
                        })

                } else if let local = sync.local {

                    return owner
                        .localAddress(myAliases: local.result, ids: ids, accountAddress: myAddress)
                        .map({ accounts -> Sync<[DomainLayer.DTO.Address]> in
                            return .local(accounts, error: local.error)
                        })
                        .catchError({ (localError) -> SyncObservable<[DomainLayer.DTO.Address]> in
                            return .error(local.error)
                        })
                } else if let error = sync.error {
                    return SyncObservable.just(.error(error))
                }
                return Observable.never()
            }
            .share()
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global(qos: .userInteractive)))
    }

    private func localAddress(myAliases: [DomainLayer.DTO.Alias], ids: [String], accountAddress: String) -> Observable<[DomainLayer.DTO.Address]> {

        return Observable.merge(addressBookRepository.listListener(by: accountAddress),
                                addressBookRepository.list(by: accountAddress))
            .flatMap({ (contacts) -> Observable<[DomainLayer.DTO.Address]> in

                let maps = contacts.reduce(into: [String : DomainLayer.DTO.Contact](), { (result, contact) in
                    result[contact.address] = contact
                })

                let accounts = ids.map({ address -> DomainLayer.DTO.Address in

                    let isMyAccount = accountAddress == address || myAliases.map { $0.name }.contains(address)
                    return DomainLayer.DTO.Address(address: address,
                                                   contact: maps[address],
                                                   isMyAccount: isMyAccount,
                                                   aliases: isMyAccount == true ? myAliases : [])
                })

                return Observable.just(accounts)
            })
    }

    func address(by ids: [String], myAddress: String) -> Observable<[DomainLayer.DTO.Address]> {

        return self.addressSync(by: ids, myAddress: myAddress)
            .flatMap({ (sync) -> Observable<[DomainLayer.DTO.Address]> in

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
