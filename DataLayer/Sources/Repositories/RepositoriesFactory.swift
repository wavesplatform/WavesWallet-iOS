//
//  FactoryRepositories.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 06.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer
import WavesSDKExtensions

import FirebaseCore
import FirebaseDatabase

import Fabric
import Crashlytics
import AppsFlyerLib
import Amplitude_iOS

//TODO: Rename Local Repository and protocol
typealias EnvironmentRepositoryProtocols = EnvironmentRepositoryProtocol & ServicesEnvironmentRepositoryProtocol

public final class RepositoriesFactory: RepositoriesFactoryProtocol {
    
    private lazy var environmentRepositoryInternal: EnvironmentRepository = EnvironmentRepository()
    
    public private(set) lazy var environmentRepository: EnvironmentRepositoryProtocol = environmentRepositoryInternal
    
    public private(set) lazy var assetsRepositoryLocal: AssetsRepositoryProtocol = AssetsRepositoryLocal()
    
    public private(set) lazy var assetsRepositoryRemote: AssetsRepositoryProtocol = AssetsRepositoryRemote(environmentRepository: environmentRepositoryInternal, spamAssetsRepository: spamAssets)
    
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
    
    public private(set) lazy var dexOrderBookRepository: DexOrderBookRepositoryProtocol = DexOrderBookRepositoryRemote(environmentRepository: environmentRepositoryInternal, spamAssetsRepository: spamAssets)
    
    public private(set) lazy var aliasesRepositoryRemote: AliasesRepositoryProtocol = AliasesRepository(environmentRepository: environmentRepositoryInternal)

    public private(set) lazy var aliasesRepositoryLocal: AliasesRepositoryProtocol = AliasesRepositoryLocal()

    public private(set) lazy var assetsBalanceSettingsRepositoryLocal: AssetsBalanceSettingsRepositoryProtocol = AssetsBalanceSettingsRepositoryLocal()

    public private(set) lazy var candlesRepository: CandlesRepositoryProtocol = CandlesRepositoryRemote(environmentRepository: environmentRepositoryInternal, matcherRepository: matcherRepository)
    
    public private(set) lazy var lastTradesRespository: LastTradesRepositoryProtocol = LastTradesRepositoryRemote(environmentRepository: environmentRepositoryInternal, matcherRepository: matcherRepository)
    
    public private(set) lazy var coinomatRepository: CoinomatRepositoryProtocol = CoinomatRepository()
    
    public private(set) lazy var addressRepository: AddressRepositoryProtocol = AddressRepositoryRemote(environmentRepository: environmentRepositoryInternal)

    public private(set) lazy var notificationNewsRepository: NotificationNewsRepositoryProtocol = NotificationNewsRepository()
    
    public private(set) lazy var applicationVersionRepository: ApplicationVersionRepositoryProtocol = ApplicationVersionRepository()
    
    public private(set) lazy var analyticManager: AnalyticManagerProtocol = {
        return AnalyticManager()
    }()
    
    public private(set) lazy var spamAssets: SpamAssetsRepositoryProtocol = {
        return SpamAssetsRepository(environmentRepository: environmentRepositoryInternal,
                                    accountSettingsRepository: accountSettingsRepository)
    }()
    
    public private(set) lazy var gatewayRepository: GatewayRepositoryProtocol = GatewayRepository(environmentRepository: environmentRepositoryInternal)
    
    public private(set) lazy var widgetSettingsStorage: WidgetSettingsRepositoryProtocol = WidgetSettingsRepositoryStorage()
    
    public private(set) lazy var matcherRepository: MatcherRepositoryProtocol = MatcherRepositoryLocal(matcherRepositoryRemote: matcherRepositoryRemote)
        
    public private(set) lazy var matcherRepositoryRemote: MatcherRepositoryProtocol = MatcherRepositoryRemote(environmentRepository: environmentRepositoryInternal)

    
    public struct Resources {
        
        public typealias PathForFile = String
        
        let googleServiceInfo: PathForFile
        let appsflyerInfo: PathForFile
        let amplitudeInfo: PathForFile
        let sentryIoInfoPath: PathForFile

        public init(googleServiceInfo: PathForFile,
                    appsflyerInfo: PathForFile,
                    amplitudeInfo: PathForFile,
                    sentryIoInfoPath: PathForFile) {
            
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
        
        if let root = NSDictionary(contentsOfFile: resources.appsflyerInfo)?["Appsflyer"] as? NSDictionary {
            if let devKey = root["AppsFlyerDevKey"] as? String,
                let appId = root["AppleAppID"] as? String {
                AppsFlyerTracker.shared().appsFlyerDevKey = devKey
                AppsFlyerTracker.shared().appleAppID = appId
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
        
            AppsFlyerTracker.shared()?.isDebug = true
        #else
            AppsFlyerTracker.shared()?.isDebug = false
        #endif
        
    }
}
