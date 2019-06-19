//
//  FactoryInteractors.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 06.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDK

private struct AuthorizationInteractorLocalizableImp: AuthorizationInteractorLocalizable {
    var fallbackTitle: String {
        //TODO: Experement
        return ""
//        return Localizable.Waves.Biometric.localizedFallbackTitle
    }
    var cancelTitle: String {
        //TODO: Experement
        return ""
//        return Localizable.Waves.Biometric.localizedCancelTitle
    }
    var readFromkeychain: String {
        //TODO: Experement
        return ""
//        return Localizable.Waves.Biometric.readfromkeychain
    }
    var saveInkeychain: String {
        //TODO: Experement
        return ""
//        return Localizable.Waves.Biometric.saveinkeychain
    }
}

public final class FactoryInteractors: FactoryInteractorsProtocol {

    public static var instance: FactoryInteractors!
    
    public let repositories: FactoryRepositoriesProtocol

    public private(set) lazy var accountBalance: AccountBalanceInteractorProtocol = {
        
        let interactor = AccountBalanceInteractor(authorizationInteractor: self.authorization,
                                                  balanceRepositoryRemote: repositories.accountBalanceRepositoryRemote,
                                                  environmentRepository: repositories.environmentRepository,
                                                  assetsInteractor: self.assetsInteractor,
                                                  assetsBalanceSettings: self.assetsBalanceSettings,
                                                  transactionsInteractor: self.transactions,
                                                  assetsBalanceSettingsRepository: repositories.assetsBalanceSettingsRepositoryLocal)
        return interactor
    }()

    public private(set) lazy var transactions: TransactionsInteractorProtocol = {
        
        let interactor = TransactionsInteractor(transactionsRepositoryLocal: repositories.transactionsRepositoryLocal,
                                                transactionsRepositoryRemote: repositories.transactionsRepositoryRemote,
                                                assetsInteractors: self.assetsInteractor,
                                                addressInteractors: self.address,
                                                addressRepository: repositories.addressRepository,
                                                assetsRepositoryRemote: repositories.assetsRepositoryRemote,
                                                blockRepositoryRemote: repositories.blockRemote,
                                                accountSettingsRepository: repositories.accountSettingsRepository)
        return interactor
    }()

    public private(set) lazy var address: AddressInteractorProtocol = {
        
        let interactor = AddressInteractor(addressBookRepository: repositories.addressBookRepository,
                                            aliasesInteractor: self.aliases)
        return interactor
    }()

    public private(set) lazy var authorization: AuthorizationInteractorProtocol = {

        let interactor = AuthorizationInteractor(localWalletRepository: repositories.walletsRepositoryLocal,
                                                 localWalletSeedRepository: repositories.walletSeedRepositoryLocal,
                                                 remoteAuthenticationRepository: repositories.authenticationRepositoryRemote,
                                                 accountSettingsRepository: repositories.accountSettingsRepository,
                                                 localizable: AuthorizationInteractorLocalizableImp())

        return interactor
    }()

    public private(set) lazy var aliases: AliasesInteractorProtocol = {

        let interactor = AliasesInteractor(aliasesRepositoryRemote: repositories.aliasesRepositoryRemote,
                                           aliasesRepositoryLocal: repositories.aliasesRepositoryLocal)

        return interactor
    }()

    public private(set) lazy var assetsBalanceSettings: AssetsBalanceSettingsInteractorProtocol = {
        
        let interactor = AssetsBalanceSettingsInteractor(assetsBalanceSettingsRepositoryLocal: repositories.assetsBalanceSettingsRepositoryLocal,
                                                         environmentRepository: repositories.environmentRepository,
                                                         authorizationInteractor: authorization)

        return interactor
    }()

    public private(set) lazy var migrationInteractor: MigrationInteractor = {
        
        return MigrationInteractor(walletsRepository: repositories.walletsRepositoryLocal)
    }()
    
    public private(set) lazy var applicationVersionUseCase: ApplicationVersionUseCase = ApplicationVersionUseCase(applicationVersionRepository: repositories.applicationVersionRepository)
    
    public private(set) lazy var assetsInteractor: AssetsInteractorProtocol = {
        
        let interactor = AssetsInteractor(assetsRepositoryLocal: repositories.assetsRepositoryLocal,
                                          assetsRepositoryRemote: repositories.assetsRepositoryRemote)
        
        return interactor
    }()
    
    init(repositories: FactoryRepositoriesProtocol) {
        self.repositories = repositories
    }
    
    public class func initialization(repositories: FactoryRepositoriesProtocol) {
        self.instance = FactoryInteractors(repositories: repositories)
    }
}
