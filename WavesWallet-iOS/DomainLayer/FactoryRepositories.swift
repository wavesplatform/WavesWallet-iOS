//
//  FactoryRepositories.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 06.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

final class FactoryRepositories: FactoryRepositoriesProtocol {

    static let instance: FactoryRepositories = FactoryRepositories()

    private(set) lazy var assetsRepositoryLocal: AssetsRepositoryProtocol = AssetsRepositoryLocal()
    private(set) lazy var assetsRepositoryRemote: AssetsRepositoryProtocol = AssetsRepositoryRemote(environmentRepository: self.environmentRepository)
    
    private(set) lazy var accountBalanceRepositoryLocal: AccountBalanceRepositoryProtocol = AccountBalanceRepositoryLocal()
    private(set) lazy var accountBalanceRepositoryRemote: AccountBalanceRepositoryProtocol = AccountBalanceRepositoryRemote(environmentRepository: self.environmentRepository)

    private(set) lazy var transactionsRepositoryLocal: TransactionsRepositoryProtocol = TransactionsRepositoryLocal()
    private(set) lazy var transactionsRepositoryRemote: TransactionsRepositoryProtocol = TransactionsRepositoryRemote(environmentRepository: self.environmentRepository)

    private(set) lazy var blockRemote: BlockRepositoryProtocol = BlockRepositoryRemote(environmentRepository: self.environmentRepository)

    private(set) lazy var walletsRepositoryLocal: WalletsRepositoryProtocol = WalletsRepositoryLocal()

    private(set) lazy var walletSeedRepositoryLocal: WalletSeedRepositoryProtocol = WalletSeedRepositoryLocal()

    private(set) lazy var authenticationRepositoryRemote: AuthenticationRepositoryProtocol = AuthenticationRepositoryRemote()

    private(set) lazy var environmentRepository: EnvironmentRepositoryProtocol = EnvironmentRepository()

    private(set) lazy var accountSettingsRepository: AccountSettingsRepositoryProtocol = AccountSettingsRepository()

    private(set) lazy var addressBookRepository: AddressBookRepositoryProtocol = AddressBookRepository()

    private(set) lazy var dexRealmRepository: DexRealmRepositoryProtocol = DexRealmRepositoryLocal()
    
    private(set) lazy var dexPairsPriceRepository: DexPairsPriceRepositoryProtocol = DexPairsPriceRepositoryRemote(environmentRepository: self.environmentRepository)
    
    private(set) lazy var dexOrderBookRepository: DexOrderBookRepositoryProtocol = DexOrderBookRepositoryRemote(environmentRepository: self.environmentRepository)
    
    private(set) lazy var aliasesRepository: AliasesRepositoryProtocol = AliasesRepository(environmentRepository: self.environmentRepository)

    private(set) lazy var aliasesRepositoryLocal: AliasesRepositoryProtocol = AliasesRepositoryLocal()

    private(set) lazy var assetsBalanceSettingsRepositoryLocal: AssetsBalanceSettingsRepositoryProtocol = AssetsBalanceSettingsRepositoryLocal()

    private(set) lazy var candlesRepository: CandlesRepositoryProtocol = CandlesRepositoryRemote(environmentRepository: self.environmentRepository)
    
    private(set) lazy var lastTradesRespository: LastTradesRepositoryProtocol = LastTradesRepositoryRemote(environmentRepository: self.environmentRepository)
    
    private(set) lazy var coinomatRepository: CoinomatRepositoryProtocol = CoinomatRepository()
    
    private(set) lazy var matcherRepository: MatcherRepositoryProtocol = MatcherRepositoryRemote(environmentRepository: self.environmentRepository)
    
    fileprivate init() {}
}
