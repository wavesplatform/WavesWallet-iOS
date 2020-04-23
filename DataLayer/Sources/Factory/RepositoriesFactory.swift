//
//  FactoryRepositories.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 06.08.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Foundation
import WavesSDKExtensions

import FirebaseCore
import FirebaseDatabase

import Amplitude_iOS
import Crashlytics
import Fabric

private struct Constants {
    static let firebaseAppWavesPlatform: String = "WavesPlatform"
}

typealias ExtensionsEnvironmentRepositoryProtocols = EnvironmentRepositoryProtocol & ServicesEnvironmentRepositoryProtocol

public final class RepositoriesFactory: RepositoriesFactoryProtocol {
    
    private lazy var wavesSDKServices: WavesSDKServices = WavesSDKServicesImp()
    
    private lazy var environmentRepositoryInternal: EnvironmentRepository = EnvironmentRepository()
    
    public private(set) lazy var environmentRepository: EnvironmentRepositoryProtocol = environmentRepositoryInternal
    
    public private(set) lazy var assetsRepositoryLocal: AssetsRepositoryProtocol = AssetsRepositoryLocal()
    
    public private(set) lazy var assetsRepositoryRemote: AssetsRepositoryProtocol =
        AssetsRepositoryRemote(spamAssetsRepository: spamAssets,
                               accountSettingsRepository: accountSettingsRepository,
                               environmentRepository: environmentRepository,
                               wavesSDKServices: wavesSDKServices)
    
    public private(set) lazy var accountBalanceRepositoryLocal: AccountBalanceRepositoryProtocol = AccountBalanceRepositoryLocal()
    
    public private(set) lazy var accountBalanceRepositoryRemote: AccountBalanceRepositoryProtocol =
        AccountBalanceRepositoryRemote(wavesSDKServices: wavesSDKServices)
    
    public private(set) lazy var transactionsRepositoryLocal: TransactionsRepositoryProtocol = TransactionsRepositoryLocal()
    
    public private(set) lazy var transactionsRepositoryRemote: TransactionsRepositoryProtocol =
        TransactionsRepositoryRemote(environmentRepository: environmentRepositoryInternal)
    
    public private(set) lazy var blockRemote: BlockRepositoryProtocol =
        BlockRepositoryRemote(wavesSDKServices: wavesSDKServices)
    
    public private(set) lazy var walletsRepositoryLocal: WalletsRepositoryProtocol =
        WalletsRepositoryLocal(environmentRepository: environmentRepositoryInternal)
    
    public private(set) lazy var walletSeedRepositoryLocal: WalletSeedRepositoryProtocol = WalletSeedRepositoryLocal()
    
    public private(set) lazy var authenticationRepositoryRemote: AuthenticationRepositoryProtocol =
        AuthenticationRepositoryRemote()
    
    public private(set) lazy var accountSettingsRepository: AccountSettingsRepositoryProtocol = AccountSettingsRepository()
    
    public private(set) lazy var addressBookRepository: AddressBookRepositoryProtocol = AddressBookRepository()
    
    public private(set) lazy var dexRealmRepository: DexRealmRepositoryProtocol = DexRealmRepositoryLocal()
    
    public private(set) lazy var dexPairsPriceRepository: DexPairsPriceRepositoryProtocol =
        DexPairsPriceRepositoryRemote(environmentRepository: environmentRepositoryInternal,
                                      matcherRepository: matcherRepositoryRemote,
                                      assetsRepository: assetsRepositoryRemote,
                                      wavesSDKServices: wavesSDKServices)
    
    public private(set) lazy var dexOrderBookRepository: DexOrderBookRepositoryProtocol =
        DexOrderBookRepositoryRemote(spamAssetsRepository: spamAssets,
                                     matcherRepository: matcherRepositoryRemote,
                                     assetsRepository: assetsRepositoryRemote,
                                     waveSDKServices: wavesSDKServices)
    
    public private(set) lazy var aliasesRepositoryRemote: AliasesRepositoryProtocol =
        AliasesRepository(wavesSDKServices: wavesSDKServices)
    
    public private(set) lazy var aliasesRepositoryLocal: AliasesRepositoryProtocol = AliasesRepositoryLocal()
    
    public private(set) lazy var assetsBalanceSettingsRepositoryLocal: AssetsBalanceSettingsRepositoryProtocol =
        AssetsBalanceSettingsRepositoryLocal()
    
    public private(set) lazy var candlesRepository: CandlesRepositoryProtocol =
        CandlesRepositoryRemote(matcherRepository: matcherRepository,
                                developmentConfigsRepository: developmentConfigsRepository,
                                wavesSDKServices: wavesSDKServices)
    
    public private(set) lazy var lastTradesRespository: LastTradesRepositoryProtocol =
        LastTradesRepositoryRemote(environmentRepository: environmentRepositoryInternal, matcherRepository: matcherRepository)
    
    public private(set) lazy var coinomatRepository: CoinomatRepositoryProtocol = CoinomatRepository()
    
    public private(set) lazy var addressRepository: AddressRepositoryProtocol =
        AddressRepositoryRemote(wavesSDKServices: wavesSDKServices)
    
    public private(set) lazy var notificationNewsRepository: NotificationNewsRepositoryProtocol = NotificationNewsRepository()
    
    public private(set) lazy var applicationVersionRepository: ApplicationVersionRepositoryProtocol =
        ApplicationVersionRepository()
    
    public private(set) lazy var analyticManager: AnalyticManagerProtocol = {
        AnalyticManager()
    }()
    
    public private(set) lazy var spamAssets: SpamAssetsRepositoryProtocol = {
        SpamAssetsRepository(environmentRepository: environmentRepositoryInternal,
                             accountSettingsRepository: accountSettingsRepository)
    }()
    
    public private(set) lazy var gatewayRepository: GatewayRepositoryProtocol =
        GatewayRepository(environmentRepository: environmentRepositoryInternal)
    
    public private(set) lazy var widgetSettingsStorage: WidgetSettingsRepositoryProtocol = WidgetSettingsRepositoryStorage()
    
    public private(set) lazy var matcherRepository: MatcherRepositoryProtocol =
        MatcherRepositoryLocal(matcherRepositoryRemote: matcherRepositoryRemote)
    
    public private(set) lazy var matcherRepositoryRemote: MatcherRepositoryProtocol =
        MatcherRepositoryRemote(environmentRepository: environmentRepositoryInternal)
    
    public private(set) lazy var mobileKeeperRepository: MobileKeeperRepositoryProtocol =
        MobileKeeperRepository(repositoriesFactory: self)
    
    public private(set) lazy var developmentConfigsRepository: DevelopmentConfigsRepositoryProtocol =
        DevelopmentConfigsRepository()
    
    public private(set) lazy var tradeCategoriesConfigRepository: TradeCategoriesConfigRepositoryProtocol =
        TradeCategoriesConfigRepository(assetsRepoitory: assetsRepositoryRemote)
    
    public private(set) lazy var massTransferRepository: MassTransferRepositoryProtocol = {
        MassTransferRepositoryRemote(environmentRepository: environmentRepositoryInternal)
    }()
    
    public private(set) lazy var weGatewayRepositoryProtocol: WEGatewayRepositoryProtocol =
        WEGatewayRepository(environmentRepository: environmentRepositoryInternal,
                            developmentConfigsRepository: developmentConfigsRepository)
    
    public private(set) lazy var weOAuthRepositoryProtocol: WEOAuthRepositoryProtocol =
        WEOAuthRepository(environmentRepository: environmentRepositoryInternal,
                          developmentConfigsRepository: developmentConfigsRepository)
    
    public private(set) lazy var stakingBalanceService: StakingBalanceService =
        StakingBalanceServiceImpl(authorizationService: UseCasesFactory.instance.authorization,
                                  devConfig: UseCasesFactory.instance.repositories.developmentConfigsRepository,
                                  enviroment: environmentRepositoryInternal,
                                  accountBalanceService: UseCasesFactory.instance.accountBalance)
    
    public struct Resources {
        public typealias PathForFile = String
        
        let googleServiceInfo: PathForFile
        let googleServiceInfoForWavesPlatform: PathForFile
        let appsflyerInfo: PathForFile
        let amplitudeInfo: PathForFile
        let sentryIoInfoPath: PathForFile
        
        public init(googleServiceInfo: PathForFile,
                    appsflyerInfo: PathForFile,
                    amplitudeInfo: PathForFile,
                    sentryIoInfoPath: PathForFile,
                    googleServiceInfoForWavesPlatform: PathForFile) {
            self.googleServiceInfoForWavesPlatform = googleServiceInfoForWavesPlatform
            self.googleServiceInfo = googleServiceInfo
            self.appsflyerInfo = appsflyerInfo
            self.amplitudeInfo = amplitudeInfo
            self.sentryIoInfoPath = sentryIoInfoPath
        }
    }
    
    public init(resources: Resources) {
        if let options = FirebaseOptions(contentsOfFile: resources.googleServiceInfo) {
            FirebaseApp.configure(options: options)
            Database.database().isPersistenceEnabled = false
            Fabric.with([Crashlytics.self])
        }
        
        if let options = FirebaseOptions(contentsOfFile: resources.googleServiceInfoForWavesPlatform) {
            FirebaseApp.configure(name: Constants.firebaseAppWavesPlatform, options: options)
            if let app = FirebaseApp.app(name: Constants.firebaseAppWavesPlatform) {
                Database.database(app: app).isPersistenceEnabled = false
            }
        }
        
        if let apiKey = NSDictionary(contentsOfFile: resources.amplitudeInfo)?["API_KEY"] as? String {
            Amplitude.instance()?.initializeApiKey(apiKey)
            Amplitude.instance()?.setDeviceId(UIDevice.uuid)
        }
        
        SentryManager.initialization(sentryIoInfoPath: resources.sentryIoInfoPath)
        
        #if DEBUG || TEST
            SweetLogger.current.add(plugin: SweetLoggerConsole(visibleLevels: [.warning, .debug, .error],
                                                               isShortLog: true))
            
        #endif
    }
}
