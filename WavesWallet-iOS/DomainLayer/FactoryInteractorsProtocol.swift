//
//  FactoryInteractor.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 06.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

protocol FactoryInteractorsProtocol {
    var assetsInteractor: AssetsInteractorProtocol { get }    
    var accountBalance: AccountBalanceInteractorProtocol { get }
    var transactions: TransactionsInteractorProtocol { get }
    var accounts: AccountsInteractorProtocol { get }
    var authorization: AuthorizationInteractorProtocol { get }
    var aliases: AliasesInteractorProtocol { get }
    var assetsBalanceSettings: AssetsBalanceSettingsInteractorProtocol { get }
    var migrationInteractor: MigrationInteractor { get }
}
