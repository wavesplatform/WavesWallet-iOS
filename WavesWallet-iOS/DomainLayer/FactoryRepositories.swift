//
//  FactoryRepositories.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 06.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

//TODO: Rename Local Repository and protocol
final class FactoryRepositories: FactoryRepositoriesProtocol {

    static let instance: FactoryRepositories = FactoryRepositories()
    
    private(set) lazy var environmentRepository: EnvironmentRepositoryProtocol = EnvironmentRepository()
    
    private(set) lazy var applicationEnviroment: ApplicationEnviromentUseCaseProtocol = ApplicationEnviromentUseCase(enviromentRepository: self.environmentRepository)
    
    private(set) lazy var assetsRepositoryLocal: AssetsRepositoryProtocol = AssetsRepositoryLocal()
    
    private(set) lazy var assetsRepositoryRemote: AssetsRepositoryProtocol = AssetsRepositoryRemote(applicationEnviroment: applicationEnviroment.environment())
    
    private(set) lazy var accountBalanceRepositoryLocal: AccountBalanceRepositoryProtocol = AccountBalanceRepositoryLocal()
    private(set) lazy var accountBalanceRepositoryRemote: AccountBalanceRepositoryProtocol = AccountBalanceRepositoryRemote(applicationEnviroment: applicationEnviroment.environment())

    private(set) lazy var transactionsRepositoryLocal: TransactionsRepositoryProtocol = TransactionsRepositoryLocal()
    private(set) lazy var transactionsRepositoryRemote: TransactionsRepositoryProtocol = TransactionsRepositoryRemote(applicationEnviroment: applicationEnviroment.environment())

    private(set) lazy var blockRemote: BlockRepositoryProtocol = BlockRepositoryRemote(applicationEnviroment: applicationEnviroment.environment())

    private(set) lazy var walletsRepositoryLocal: WalletsRepositoryProtocol = WalletsRepositoryLocal()

    private(set) lazy var walletSeedRepositoryLocal: WalletSeedRepositoryProtocol = WalletSeedRepositoryLocal()

    private(set) lazy var authenticationRepositoryRemote: AuthenticationRepositoryProtocol = AuthenticationRepositoryRemote()

  

    private(set) lazy var accountSettingsRepository: AccountSettingsRepositoryProtocol = AccountSettingsRepository()

    private(set) lazy var addressBookRepository: AddressBookRepositoryProtocol = AddressBookRepository()

    private(set) lazy var dexRealmRepository: DexRealmRepositoryProtocol = DexRealmRepositoryLocal()
    
    private(set) lazy var dexPairsPriceRepository: DexPairsPriceRepositoryProtocol = DexPairsPriceRepositoryRemote(applicationEnviroment: applicationEnviroment.environment())
    
    private(set) lazy var dexOrderBookRepository: DexOrderBookRepositoryProtocol = DexOrderBookRepositoryRemote(applicationEnviroment: applicationEnviroment.environment())
    
    private(set) lazy var aliasesRepositoryRemote: AliasesRepositoryProtocol = AliasesRepository(applicationEnviroment: applicationEnviroment.environment())

    private(set) lazy var aliasesRepositoryLocal: AliasesRepositoryProtocol = AliasesRepositoryLocal()

    private(set) lazy var assetsBalanceSettingsRepositoryLocal: AssetsBalanceSettingsRepositoryProtocol = AssetsBalanceSettingsRepositoryLocal()

    private(set) lazy var candlesRepository: CandlesRepositoryProtocol = CandlesRepositoryRemote(applicationEnviroment: applicationEnviroment.environment())
    
    private(set) lazy var lastTradesRespository: LastTradesRepositoryProtocol = LastTradesRepositoryRemote(applicationEnviroment: applicationEnviroment.environment())
    
    private(set) lazy var coinomatRepository: CoinomatRepositoryProtocol = CoinomatRepository()
    
    private(set) lazy var matcherRepository: MatcherRepositoryProtocol = MatcherRepositoryRemote(applicationEnviroment: applicationEnviroment.environment())

    private(set) lazy var addressRepository: AddressRepositoryProtocol = AddressRepositoryRemote(applicationEnviroment: applicationEnviroment.environment())

    private(set) lazy var notificationNewsRepository: NotificationNewsRepositoryProtocol = NotificationNewsRepository()
        
    fileprivate init() {}
}
