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

import Amplitude_iOS
import Crashlytics
import Fabric
import FirebaseCore
import FirebaseDatabase

private struct Constants {
    static let firebaseAppWavesPlatform: String = "WavesPlatform"
}

public final class RepositoriesFactory: RepositoriesFactoryProtocol {
    private let servicesFactory: ServicesFactory

    private lazy var environmentRepositoryInternal: EnvironmentRepository = EnvironmentRepository()

    public private(set) lazy var environmentRepository: EnvironmentRepositoryProtocol = environmentRepositoryInternal

    public private(set) lazy var assetsRepositoryLocal: AssetsRepositoryProtocol = AssetsRepositoryLocal()

    public private(set) lazy var assetsRepositoryRemote: AssetsRepositoryProtocol =
        AssetsRepositoryRemote(spamAssetsRepository: spamAssets,
                               accountSettingsRepository: accountSettingsRepository,
                               environmentRepository: environmentRepository,
                               wavesSDKServices: servicesFactory.wavesSDKServices)

    public private(set) lazy var accountBalanceRepositoryRemote: AccountBalanceRepositoryProtocol =
        AccountBalanceRepositoryRemote(wavesSDKServices: servicesFactory.wavesSDKServices)

    public private(set) lazy var transactionsDAO: TransactionsDAO = TransactionsDAOImp()

    public private(set) lazy var transactionsRepository: TransactionsRepositoryProtocol =
        TransactionsRepository(wavesSDKServices: servicesFactory.wavesSDKServices)

    public private(set) lazy var blockRemote: BlockRepositoryProtocol =
        BlockRepositoryRemote(wavesSDKServices: servicesFactory.wavesSDKServices)

    public private(set) lazy var walletsRepositoryLocal: WalletsRepositoryProtocol =
        WalletsRepositoryLocal(environmentRepository: environmentRepositoryInternal)

    public private(set) lazy var walletSeedRepositoryLocal: WalletSeedRepositoryProtocol = WalletSeedRepositoryLocal()

    public private(set) lazy var authenticationRepositoryRemote: AuthenticationRepositoryProtocol =
        AuthenticationRepository(serverEnvironmentRepository: serverEnvironmentUseCase)

    public private(set) lazy var accountSettingsRepository: AccountSettingsRepositoryProtocol =
        AccountSettingsRepository(spamAssetsService: self.servicesFactory.spamAssetsService)

    public private(set) lazy var addressBookRepository: AddressBookRepositoryProtocol = AddressBookRepository()

    public private(set) lazy var dexRealmRepository: DexRealmRepositoryProtocol = DexRealmRepositoryLocal()

    public private(set) lazy var dexPairsPriceRepository: DexPairsPriceRepositoryProtocol =
        DexPairsPriceRepositoryRemote(matcherRepository: matcherRepositoryRemote,
                                      assetsRepository: assetsRepositoryRemote,
                                      wavesSDKServices: servicesFactory.wavesSDKServices)

    public private(set) lazy var dexOrderBookRepository: DexOrderBookRepositoryProtocol =
        DexOrderBookRepositoryRemote(spamAssetsRepository: spamAssets,
                                     matcherRepository: matcherRepositoryRemote,
                                     assetsRepository: assetsRepositoryRemote,
                                     waveSDKServices: servicesFactory.wavesSDKServices)

    public private(set) lazy var aliasesRepositoryRemote: AliasesRepositoryProtocol =
        AliasesRepository(wavesSDKServices: servicesFactory.wavesSDKServices)

    public private(set) lazy var aliasesRepositoryLocal: AliasesRepositoryProtocol = AliasesRepositoryLocal()

    public private(set) lazy var assetsBalanceSettingsRepositoryLocal: AssetsBalanceSettingsRepositoryProtocol =
        AssetsBalanceSettingsRepositoryLocal()

    public private(set) lazy var candlesRepository: CandlesRepositoryProtocol =
        CandlesRepositoryRemote(matcherRepository: matcherRepository,
                                developmentConfigsRepository: developmentConfigsRepository,
                                wavesSDKServices: servicesFactory.wavesSDKServices)

    public private(set) lazy var lastTradesRespository: LastTradesRepositoryProtocol =
        LastTradesRepositoryRemote(matcherRepository: matcherRepository,
                                   wavesSDKServices: servicesFactory.wavesSDKServices)

    public private(set) lazy var coinomatRepository: CoinomatRepositoryProtocol = CoinomatRepository()

    public private(set) lazy var addressRepository: AddressRepositoryProtocol =
        AddressRepositoryRemote(wavesSDKServices: servicesFactory.wavesSDKServices)

    public private(set) lazy var notificationNewsRepository: NotificationNewsRepositoryProtocol = NotificationNewsRepository()

    public private(set) lazy var applicationVersionRepository: ApplicationVersionRepositoryProtocol =
        ApplicationVersionRepository()

    public private(set) lazy var analyticManager: AnalyticManagerProtocol = {
        AnalyticManager()
    }()

    public private(set) lazy var spamAssets: SpamAssetsRepositoryProtocol = {
        SpamAssetsRepository(environmentRepository: environmentRepository,
                             accountSettingsRepository: accountSettingsRepository,
                             spamAssetsService: self.servicesFactory.spamAssetsService)
    }()

    public private(set) lazy var gatewayRepository: GatewayRepositoryProtocol = GatewayRepository()

    public private(set) lazy var widgetSettingsStorage: WidgetSettingsRepositoryProtocol = WidgetSettingsRepositoryStorage()

    public private(set) lazy var matcherRepository: MatcherRepositoryProtocol =
        MatcherRepositoryLocal(matcherRepositoryRemote: matcherRepositoryRemote)

    public private(set) lazy var matcherRepositoryRemote: MatcherRepositoryProtocol =
        MatcherRepositoryRemote(wavesSDKServices: servicesFactory.wavesSDKServices)

    public private(set) lazy var mobileKeeperRepository: MobileKeeperRepositoryProtocol =
        MobileKeeperRepository(repositoriesFactory: self)

    public private(set) lazy var developmentConfigsRepository: DevelopmentConfigsRepositoryProtocol =
        DevelopmentConfigsRepository()

    public private(set) lazy var tradeCategoriesConfigRepository: TradeCategoriesConfigRepositoryProtocol =
        TradeCategoriesConfigRepository(assetsRepoitory: assetsRepositoryRemote)

    public private(set) lazy var massTransferRepository: MassTransferRepositoryProtocol = {
        MassTransferRepositoryRemote(wavesSDKServices: servicesFactory.wavesSDKServices)
    }()

    public private(set) lazy var weGatewayRepository: WEGatewayRepositoryProtocol =
        WEGatewayRepository(developmentConfigsRepository: developmentConfigsRepository)

    public private(set) lazy var weOAuthRepository: WEOAuthRepositoryProtocol =
        WEOAuthRepository(developmentConfigsRepository: developmentConfigsRepository,
                          serverEnvironmentRepository: serverEnvironmentUseCase)

    public private(set) lazy var stakingBalanceService: StakingBalanceService =
        StakingBalanceServiceImpl(authorizationService: UseCasesFactory.instance.authorization,
                                  devConfig: UseCasesFactory.instance.repositories.developmentConfigsRepository,
                                  accountBalanceService: UseCasesFactory.instance.accountBalance,
                                  serverEnvironmentUseCase: serverEnvironmentUseCase,
                                  wavesSDKServices: servicesFactory.wavesSDKServices)

    public private(set) lazy var serverTimestampRepository: ServerTimestampRepository = {
        ServerTimestampRepositoryImp(timestampServerService: servicesFactory.timestampServerService)
    }()

    public private(set) lazy var gatewaysWavesRepository: GatewaysWavesRepository = {
        GatewaysWavesRepositoryImp()
    }()

    public private(set) lazy var serverEnvironmentUseCase: ServerEnvironmentRepository = {
        ServerEnvironmentRepositoryImp(serverTimestampRepository: serverTimestampRepository,
                                       environmentRepository: environmentRepository)
    }()

    public private(set) lazy var userRepository: UserRepository = {
        UserRepositoryImp(serverEnvironmentRepository: serverEnvironmentUseCase, weOAuthRepository: weOAuthRepository)
    }()

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

    public init(resources: Resources,
                services: ServicesFactory) {
        servicesFactory = services

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
