//
//  FactoryRepositories.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 06.08.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation

public protocol RepositoriesFactoryProtocol {
    var assetsRepositoryLocal: AssetsRepositoryProtocol { get }
    var assetsRepositoryRemote: AssetsRepositoryProtocol { get }

    var accountBalanceRepositoryRemote: AccountBalanceRepositoryProtocol { get }

    var transactionsDAO: TransactionsDAO { get }
    var transactionsRepository: TransactionsRepositoryProtocol { get }

    var blockRemote: BlockRepositoryProtocol { get }

    var walletsRepositoryLocal: WalletsRepositoryProtocol { get }
    var walletSeedRepositoryLocal: WalletSeedRepositoryProtocol { get }

    var authenticationRepositoryRemote: AuthenticationRepositoryProtocol { get }

    var environmentRepository: EnvironmentRepositoryProtocol { get }

    var accountSettingsRepository: AccountSettingsRepositoryProtocol { get }

    var addressBookRepository: AddressBookRepositoryProtocol { get }

    var dexRealmRepository: DexRealmRepositoryProtocol { get }

    var dexPairsPriceRepository: DexPairsPriceRepositoryProtocol { get }

    var dexOrderBookRepository: DexOrderBookRepositoryProtocol { get }

    var aliasesRepositoryRemote: AliasesRepositoryProtocol { get }
    var aliasesRepositoryLocal: AliasesRepositoryProtocol { get }

    var assetsBalanceSettingsRepositoryLocal: AssetsBalanceSettingsRepositoryProtocol { get }

    var candlesRepository: CandlesRepositoryProtocol { get }

    var lastTradesRespository: LastTradesRepositoryProtocol { get }

    var coinomatRepository: CoinomatRepositoryProtocol { get }

    var matcherRepository: MatcherRepositoryProtocol { get }

    var addressRepository: AddressRepositoryProtocol { get }

    var notificationNewsRepository: NotificationNewsRepositoryProtocol { get }

    var applicationVersionRepository: ApplicationVersionRepositoryProtocol { get }

    // TODO: Rename
    var analyticManager: AnalyticManagerProtocol { get }

    var spamAssets: SpamAssetsRepositoryProtocol { get }

    var gatewayRepository: GatewayRepositoryProtocol { get }

    var widgetSettingsStorage: WidgetSettingsRepositoryProtocol { get }

    var mobileKeeperRepository: MobileKeeperRepositoryProtocol { get }

    var developmentConfigsRepository: DevelopmentConfigsRepositoryProtocol { get }

    var tradeCategoriesConfigRepository: TradeCategoriesConfigRepositoryProtocol { get }

    var massTransferRepository: MassTransferRepositoryProtocol { get }

    var weGatewayRepository: WEGatewayRepositoryProtocol { get }

    var weOAuthRepository: WEOAuthRepositoryProtocol { get }

    var stakingBalanceService: StakingBalanceService { get }

    var serverTimestampRepository: ServerTimestampRepository { get }

    var gatewaysWavesRepository: GatewaysWavesRepository { get }

    var serverEnvironmentUseCase: ServerEnvironmentRepository { get }

    var userRepository: UserRepository { get }
    
    var adCashGRPCService: AdCashGRPCService { get }
}
