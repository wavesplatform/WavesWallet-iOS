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
    private(set) lazy var assetsRepositoryRemote: AssetsRepositoryProtocol = AssetsRepositoryRemote()

    private(set) lazy var leasingRepositoryLocal: LeasingTransactionRepositoryProtocol = LeasingTransactionRepositoryLocal()
    private(set) lazy var leasingRepositoryRemote: LeasingTransactionRepositoryProtocol = LeasingTransactionRepositoryRemote()

    private(set) lazy var accountBalanceRepositoryLocal: AccountBalanceRepositoryProtocol = AccountBalanceRepositoryLocal()
    private(set) lazy var accountBalanceRepositoryRemote: AccountBalanceRepositoryProtocol = AccountBalanceRepositoryRemote()

    fileprivate init() {}
}
