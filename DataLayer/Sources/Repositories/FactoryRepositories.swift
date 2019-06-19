//
//  FactoryRepositories.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 06.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer

//TODO: Rename Local Repository and protocol

typealias EnvironmentRepositoryProtocols = EnvironmentRepositoryProtocol & ServicesEnvironmentRepositoryProtocol

public final class FactoryRepositories: FactoryRepositoriesProtocol {

    public static let instance: FactoryRepositories = FactoryRepositories()
    
    private lazy var environmentRepositoryInternal: EnvironmentRepository = EnvironmentRepository()
    
    public private(set) lazy var environmentRepository: EnvironmentRepositoryProtocol = environmentRepositoryInternal
    
    public private(set) lazy var assetsRepositoryLocal: AssetsRepositoryProtocol = AssetsRepositoryLocal()
    
    public private(set) lazy var assetsRepositoryRemote: AssetsRepositoryProtocol = AssetsRepositoryRemote(environmentRepository: environmentRepositoryInternal)
    
    public private(set) lazy var accountBalanceRepositoryLocal: AccountBalanceRepositoryProtocol = AccountBalanceRepositoryLocal()
    
    public private(set) lazy var accountBalanceRepositoryRemote: AccountBalanceRepositoryProtocol = AccountBalanceRepositoryRemote(environmentRepository: environmentRepositoryInternal)

    public private(set) lazy var transactionsRepositoryLocal: TransactionsRepositoryProtocol = TransactionsRepositoryLocal()
    
    public private(set) lazy var transactionsRepositoryRemote: TransactionsRepositoryProtocol = TransactionsRepositoryRemote(environmentRepository: environmentRepositoryInternal)

    public private(set) lazy var blockRemote: BlockRepositoryProtocol = BlockRepositoryRemote(environmentRepository: environmentRepositoryInternal)

    public private(set) lazy var walletsRepositoryLocal: WalletsRepositoryProtocol = WalletsRepositoryLocal()

    public private(set) lazy var walletSeedRepositoryLocal: WalletSeedRepositoryProtocol = WalletSeedRepositoryLocal()

    public private(set) lazy var authenticationRepositoryRemote: AuthenticationRepositoryProtocol = AuthenticationRepositoryRemote()

    public private(set) lazy var accountSettingsRepository: AccountSettingsRepositoryProtocol = AccountSettingsRepository()

    public private(set) lazy var addressBookRepository: AddressBookRepositoryProtocol = AddressBookRepository()

    public private(set) lazy var dexRealmRepository: DexRealmRepositoryProtocol = DexRealmRepositoryLocal()
    
    public private(set) lazy var dexPairsPriceRepository: DexPairsPriceRepositoryProtocol = DexPairsPriceRepositoryRemote(environmentRepository: environmentRepositoryInternal)
    
    public private(set) lazy var dexOrderBookRepository: DexOrderBookRepositoryProtocol = DexOrderBookRepositoryRemote(environmentRepository: environmentRepositoryInternal)
    
    public private(set) lazy var aliasesRepositoryRemote: AliasesRepositoryProtocol = AliasesRepository(environmentRepository: environmentRepositoryInternal)

    public private(set) lazy var aliasesRepositoryLocal: AliasesRepositoryProtocol = AliasesRepositoryLocal()

    public private(set) lazy var assetsBalanceSettingsRepositoryLocal: AssetsBalanceSettingsRepositoryProtocol = AssetsBalanceSettingsRepositoryLocal()

    public private(set) lazy var candlesRepository: CandlesRepositoryProtocol = CandlesRepositoryRemote(environmentRepository: environmentRepositoryInternal)
    
    public private(set) lazy var lastTradesRespository: LastTradesRepositoryProtocol = LastTradesRepositoryRemote(environmentRepository: environmentRepositoryInternal)
    
    public private(set) lazy var coinomatRepository: CoinomatRepositoryProtocol = CoinomatRepository()
    
    public private(set) lazy var matcherRepository: MatcherRepositoryProtocol = MatcherRepositoryRemote(environmentRepository: environmentRepositoryInternal)

    public private(set) lazy var addressRepository: AddressRepositoryProtocol = AddressRepositoryRemote(environmentRepository: environmentRepositoryInternal)

    public private(set) lazy var notificationNewsRepository: NotificationNewsRepositoryProtocol = NotificationNewsRepository()
    
    public private(set) lazy var applicationVersionRepository: ApplicationVersionRepositoryProtocol = ApplicationVersionRepository()
                
    fileprivate init() {}
}
