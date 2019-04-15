//
//  FactoryInteractors.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 06.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

private struct AuthorizationInteractorLocalizableImp: AuthorizationInteractorLocalizable {
    var fallbackTitle: String {
        return Localizable.Waves.Biometric.localizedFallbackTitle
    }
    var cancelTitle: String {
        return Localizable.Waves.Biometric.localizedCancelTitle
    }
    var readFromkeychain: String {
        return Localizable.Waves.Biometric.readfromkeychain
    }
    var saveInkeychain: String {
        return Localizable.Waves.Biometric.saveinkeychain
    }
}

final class FactoryInteractors: FactoryInteractorsProtocol {

    static let instance: FactoryInteractors = FactoryInteractors()

    private(set) lazy var assetsInteractor: AssetsInteractorProtocol = {

        let instance = FactoryRepositories.instance
        let interactor = AssetsInteractor(assetsRepositoryLocal: instance.assetsRepositoryLocal,
                                          assetsRepositoryRemote: instance.assetsRepositoryRemote)

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
                                                addressInteractors: self.address,
                                                addressRepository: instance.addressRepository,
                                                assetsRepositoryRemote: instance.assetsRepositoryRemote,
                                                blockRepositoryRemote: instance.blockRemote,
                                                accountSettingsRepository: instance.accountSettingsRepository)
        return interactor
    }()

    private(set) lazy var address: AddressInteractorProtocol = {

        let instance = FactoryRepositories.instance

        let interactor = AddressInteractor(addressBookRepository: instance.addressBookRepository,
                                            aliasesInteractor: self.aliases)
        return interactor
    }()

    private(set) lazy var authorization: AuthorizationInteractorProtocol = {

        let instance = FactoryRepositories.instance

        let interactor = AuthorizationInteractor(localWalletRepository: instance.walletsRepositoryLocal,
                                                 localWalletSeedRepository: instance.walletSeedRepositoryLocal,
                                                 remoteAuthenticationRepository: instance.authenticationRepositoryRemote,
                                                 accountSettingsRepository: instance.accountSettingsRepository,
                                                 localizable: AuthorizationInteractorLocalizableImp())

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

        let interactor = AssetsBalanceSettingsInteractor(assetsBalanceSettingsRepositoryLocal: instance.assetsBalanceSettingsRepositoryLocal,
                                                         environmentRepository: instance.environmentRepository,
                                                         authorizationInteractor: authorization)

        return interactor
    }()

    private(set) lazy var migrationInteractor: MigrationInteractor = {

        let instance = FactoryRepositories.instance
        return MigrationInteractor(walletsRepository: instance.walletsRepositoryLocal)
    }()
    
    fileprivate init() {}
}
