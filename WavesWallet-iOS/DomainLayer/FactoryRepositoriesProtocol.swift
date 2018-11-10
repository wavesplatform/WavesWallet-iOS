//
//  FactoryRepositories.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 06.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

protocol FactoryRepositoriesProtocol {

    var assetsRepositoryLocal: AssetsRepositoryProtocol { get }
    var assetsRepositoryRemote: AssetsRepositoryProtocol { get }

    var leasingRepositoryLocal: LeasingTransactionRepositoryProtocol { get }
    var leasingRepositoryRemote: LeasingTransactionRepositoryProtocol { get }

    var accountBalanceRepositoryLocal: AccountBalanceRepositoryProtocol { get }
    var accountBalanceRepositoryRemote: AccountBalanceRepositoryProtocol { get }

    var transactionsRepositoryLocal: TransactionsRepositoryProtocol { get }
    var transactionsRepositoryRemote: TransactionsRepositoryProtocol { get }

    var blockRemote: BlockRepositoryProtocol { get }

    var walletsRepositoryLocal: WalletsRepositoryProtocol { get }
    var walletSeedRepositoryLocal: WalletSeedRepositoryProtocol { get }

    var authenticationRepositoryRemote: AuthenticationRepositoryProtocol { get }

    var environmentRepository: EnvironmentRepositoryProtocol { get }

    var accountSettingsRepository: AccountSettingsRepositoryProtocol { get }

    var addressBookRepository: AddressBookRepositoryProtocol { get }

    var aliasesRepository: AliasesRepositoryProtocol { get }
}

protocol RepositoryCache {

    func isCache<R>(local: R, remote: R) -> Bool
    var isInvalid: Bool { get set }
}

final class RepositoriesDuplex<R> {

    private let local: R
    private let remote: R
    let cache: RepositoryCache

    init(local: R, remote: R, cache: RepositoryCache) {
        self.local = local
        self.remote = remote
        self.cache = cache
    }

    var repository: R {
        if cache.isCache(local: local, remote: remote) {
            return local
        } else {
            return remote
        }
    }
}
