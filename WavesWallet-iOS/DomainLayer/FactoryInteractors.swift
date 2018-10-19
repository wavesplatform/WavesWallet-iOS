//
//  FactoryInteractors.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 06.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

final class FactoryInteractors: FactoryInteractorsProtocol {

    static let instance: FactoryInteractors = FactoryInteractors()

    private(set) lazy var assetsInteractor: AssetsInteractorProtocol = AssetsInteractor()
    private(set) lazy var leasingInteractor: LeasingInteractorProtocol = LeasingInteractor()
    private(set) lazy var accountBalance: AccountBalanceInteractorProtocol = AccountBalanceInteractor()
    private(set) lazy var transactions: TransactionsInteractorProtocol = TransactionsInteractor()
    private(set) lazy var accounts: AccountsInteractorProtocol = AccountsInteractorMock()
    private(set) lazy var authorization: AuthorizationInteractorProtocol = AuthorizationInteractor()
    private(set) lazy var environment: EnvironmentInteractorProtocol = EnvironmentInteractor()

    fileprivate init() {}
}
