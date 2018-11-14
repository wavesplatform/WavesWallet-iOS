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
}

final class AccountsInteractorMock: AccountsInteractorProtocol {

    private let addressBookRepository: AddressBookRepositoryProtocol = FactoryRepositories.instance.addressBookRepository
    private let environmentRepository: EnvironmentRepositoryProtocol = FactoryRepositories.instance.environmentRepository
    private let aliasesRepository: AliasesRepositoryProtocol = FactoryRepositories.instance.aliasesRepository

    func accounts(by ids: [String], accountAddress: String) -> Observable<[DomainLayer.DTO.Account]> {

        return Observable.zip(addressBookRepository.list(by: accountAddress),
                              environmentRepository.accountEnvironment(accountAddress: accountAddress),
                              aliasesRepository.aliases(accountAddress: accountAddress))
            .flatMap { (contacts, environment, aliases) -> Observable<[DomainLayer.DTO.Account]> in

                let maps = contacts.reduce(into: [String : DomainLayer.DTO.Contact](), { (result, contact) in
                    result[contact.address] = contact
                })

                let accounts = ids.map({ address -> DomainLayer.DTO.Account in
                    var newAddress = address
                    if address.contains(environment.aliasScheme) {
                        newAddress = address.removeCharacters(from: environment.aliasScheme)
                    }
                    let isMyAccount = accountAddress == newAddress || aliases.map { $0.name }.contains(newAddress)
                    return DomainLayer.DTO.Account(address: newAddress, contact: maps[newAddress], isMyAccount: isMyAccount)
                })

                return Observable.just(accounts)
            }
    }
}
