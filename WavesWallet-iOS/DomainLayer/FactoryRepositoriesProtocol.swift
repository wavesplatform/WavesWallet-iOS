//
//  FactoryRepositories.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 06.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

protocol FactoryRepositoriesProtocol {

    var assetsRepositoryLocal: AssetsRepositoryProtocol { get }
    var assetsRepositoryRemote: AssetsRepositoryProtocol { get }

    var leasingRepositoryLocal: LeasingTransactionRepositoryProtocol { get }
    var leasingRepositoryRemote: LeasingTransactionRepositoryProtocol { get }

    var accountBalanceRepositoryLocal: AccountBalanceRepositoryProtocol { get }
    var accountBalanceRepositoryRemote: AccountBalanceRepositoryProtocol { get }

    var transactionsRepositoryLocal: TransactionsRepositoryProtocol { get }
    var transactionsRepositoryRemote: TransactionsRepositoryProtocol { get }
}
