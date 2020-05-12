//
//  FactoryInteractor.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 06.08.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation

public protocol UseCasesFactoryProtocol {
    var assets: AssetsUseCaseProtocol { get }    
    var accountBalance: AccountBalanceUseCaseProtocol { get }
    var transactions: TransactionsUseCaseProtocol { get }
    var address: AddressInteractorProtocol { get }
    var authorization: AuthorizationUseCaseProtocol { get }
    var aliases: AliasesUseCaseProtocol { get }
    var assetsBalanceSettings: AssetsBalanceSettingsUseCaseProtocol { get }
    var migration: MigrationUseCaseProtocol { get }
    
    var applicationVersionUseCase: ApplicationVersionUseCase { get }
    var analyticManager: AnalyticManagerProtocol { get }
    
    var oderbook: OrderBookUseCaseProtocol { get }

    var widgetSettings: WidgetSettingsUseCaseProtocol { get }
    var widgetSettingsInizialization: WidgetSettingsInizializationUseCaseProtocol { get }
    
    var correctionPairsUseCase: CorrectionPairsUseCaseProtocol { get }
    
    var weGatewayUseCase: WEGatewayUseCaseProtocol { get }
    
    var adCashDepositsUseCase: AdCashDepositsUseCaseProtocol { get }
    
    var serverEnvironmentUseCase: ServerEnvironmentRepository { get }
}
