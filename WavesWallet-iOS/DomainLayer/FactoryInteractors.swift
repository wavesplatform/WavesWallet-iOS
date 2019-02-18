//
//  FactoryInteractors.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 06.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

final class FactoryInteractors: FactoryInteractorsProtocol {

    static let instance: FactoryInteractors = FactoryInteractors()

    private(set) lazy var assetsInteractor: AssetsInteractorProtocol = {

        let instance = FactoryRepositories.instance
        let interactor = AssetsInteractor(assetsRepositoryLocal: instance.assetsRepositoryLocal,
                                          assetsRepositoryRemote: instance.assetsRepositoryRemote,
                                          accountSettingsRepository: instance.accountSettingsRepository)

        return interactor
    }()

    private(set) lazy var accountBalance: AccountBalanceInteractorProtocol = {
        let instance = FactoryRepositories.instance
        let interactor = AccountBalanceInteractor(authorizationInteractor: self.authorization,
                                                  balanceRepositoryRemote: instance.accountBalanceRepositoryRemote,
                                                  environmentRepository: instance.environmentRepository,
                                                  assetsInteractor: self.assetsInteractor,
                                                  assetsBalanceSettings: self.assetsBalanceSettings,
                                                  transactionsInteractor: self.transactions,
                                                  assetsBalanceSettingsRepository: instance.assetsBalanceSettingsRepositoryLocal)
        return interactor
    }()

    private(set) lazy var transactions: TransactionsInteractorProtocol = {

        let instance = FactoryRepositories.instance

        let interactor = TransactionsInteractor(transactionsRepositoryLocal: instance.transactionsRepositoryLocal,
                                                transactionsRepositoryRemote: instance.transactionsRepositoryRemote,
                                                assetsInteractors: self.assetsInteractor,
                                                accountsInteractors: self.accounts,
                                                addressRepository: instance.addressRepository,
                                                assetsRepositoryRemote: instance.assetsRepositoryRemote,
                                                blockRepositoryRemote: instance.blockRemote)
        return interactor
    }()

    private(set) lazy var accounts: AccountsInteractorProtocol = {

        let instance = FactoryRepositories.instance

        let interactor = AccountsInteractor(addressBookRepository: instance.addressBookRepository,
                                            aliasesInteractor: self.aliases)
        return interactor
    }()

    private(set) lazy var authorization: AuthorizationInteractorProtocol = {

        let instance = FactoryRepositories.instance

        let interactor = AuthorizationInteractor(localWalletRepository: instance.walletsRepositoryLocal,
                                                 localWalletSeedRepository: instance.walletSeedRepositoryLocal,
                                                 remoteAuthenticationRepository: instance.authenticationRepositoryRemote,
                                                 accountSettingsRepository: instance.accountSettingsRepository)

        return interactor
    }()

    private(set) lazy var aliases: AliasesInteractorProtocol = {

        let instance = FactoryRepositories.instance

        let interactor = AliasesInteractor(aliasesRepositoryRemote: instance.aliasesRepositoryRemote,
                                           aliasesRepositoryLocal: instance.aliasesRepositoryLocal)

        return interactor
    }()

    private(set) lazy var assetsBalanceSettings: AssetsBalanceSettingsInteractorProtocol = {

        let instance = FactoryRepositories.instance

        let interactor = AssetsBalanceSettingsInteractor(assetsBalanceSettingsRepositoryLocal: instance.assetsBalanceSettingsRepositoryLocal)

        return interactor
    }()

    fileprivate init() {}
}
