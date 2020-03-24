//
//  WalletInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 16/07/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import RxSwift
import WavesSDK
import WavesSDKExtensions

private struct Leasing {
    let balance: DomainLayer.DTO.SmartAssetBalance
    let transaction: [DomainLayer.DTO.SmartTransaction]
    let walletAddress: String
}

final class WalletInteractor: WalletInteractorProtocol {
    private let enviroment: DevelopmentConfigsRepositoryProtocol
    private let massTransferRepository: MassTransferRepositoryProtocol
    private let assetUseCase: AssetsUseCaseProtocol
    
    private let authorizationInteractor: AuthorizationUseCaseProtocol
    private let accountBalanceInteractor: AccountBalanceUseCaseProtocol
    private let accountSettingsRepository: AccountSettingsRepositoryProtocol
    private let applicationVersionUseCase: ApplicationVersionUseCaseProtocol
    
    private let leasingInteractor: TransactionsUseCaseProtocol
    
    private let walletsRepository: WalletsRepositoryProtocol
    
    private let disposeBag = DisposeBag()
    
    init(enviroment: DevelopmentConfigsRepositoryProtocol,
         massTransferRepository: MassTransferRepositoryProtocol,
         assetUseCase: AssetsUseCaseProtocol,
         authorizationInteractor: AuthorizationUseCaseProtocol,
         accountBalanceInteractor: AccountBalanceUseCaseProtocol,
         accountSettingsRepository: AccountSettingsRepositoryProtocol,
         applicationVersionUseCase: ApplicationVersionUseCaseProtocol,
         leasingInteractor: TransactionsUseCaseProtocol,
         walletsRepository: WalletsRepositoryProtocol) {
        self.enviroment = enviroment
        self.massTransferRepository = massTransferRepository
        self.assetUseCase = assetUseCase
        self.authorizationInteractor = authorizationInteractor
        self.accountBalanceInteractor = accountBalanceInteractor
        self.accountSettingsRepository = accountSettingsRepository
        self.applicationVersionUseCase = applicationVersionUseCase
        self.leasingInteractor = leasingInteractor
        self.walletsRepository = walletsRepository
    }
    
    func isHasAppUpdate() -> Observable<Bool> { applicationVersionUseCase.isHasNewVersion() }
    
    func setCleanWalletBanner() -> Observable<Bool> {
        return authorizationInteractor.authorizedWallet()
            .flatMap { [weak self] (signedWallet) -> Observable<Bool> in
                guard let self = self else { return Observable.empty() }
                return self.walletsRepository.wallet(by: signedWallet.wallet.publicKey)
                    .flatMap { [weak self] (wallet) -> Observable<Bool> in
                        guard let self = self else { return Observable.empty() }
                        
                        var newWallet = wallet
                        newWallet.isNeedShowWalletCleanBanner = false
                        return self.walletsRepository.saveWallet(newWallet)
                            .flatMap { (_) -> Observable<Bool> in
                                Observable.just(true)
                            }
                    }
            }
    }
    
    func isShowCleanWalletBanner() -> Observable<Bool> {
        return authorizationInteractor.authorizedWallet()
            .map { $0.wallet.isNeedShowWalletCleanBanner }
    }
    
    func assets() -> Observable<[DomainLayer.DTO.SmartAssetBalance]> {
        return authorizationInteractor
            .authorizedWallet()
            .flatMap { [weak self] wallet -> Observable<[DomainLayer.DTO.SmartAssetBalance]> in
                guard let self = self else { return Observable.never() }
                
                let assets = self.accountBalanceInteractor.balances(by: wallet)
                let settings = self.accountSettingsRepository.accountSettings(accountAddress: wallet.address)
                
                return Observable.zip(assets, settings)
                    .map { (assets, settings) -> [DomainLayer.DTO.SmartAssetBalance] in
                        
                        if let settings = settings, settings.isEnabledSpam {
                            return assets.filter { $0.asset.isSpam == false }
                        }
                        
                        return assets
                    }
            }
    }
    
    func leasing() -> Observable<WalletTypes.DTO.Leasing> {
        return Observable.merge(leasing(isNeedUpdate: true))
    }
    
    func staking() -> Observable<WalletTypes.DTO.Staking> {
        obtainMassTransfer()
            .map { massTransferTrait -> WalletTypes.DTO.Staking in
                
                let transactions = massTransferTrait.massTransferTransactions.transactions
                let profitPercent = WalletInteractor.getTotalProfitPercent(transactions: transactions,
                                                                           walletAddress: massTransferTrait.walletAddress)
                
                let totalProfit = WalletInteractor.getTotalProfit(transactions: transactions,
                                                                  walletAddress: massTransferTrait.walletAddress)
                
                let totalBalanceCurrency = DomainLayer.DTO.Balance.Currency(title: "", ticker: massTransferTrait.assetTicker)
                let totalBalanceMoney = Money(value: Decimal(totalProfit), massTransferTrait.precision ?? 0)
                
                let totalBalance = DomainLayer.DTO.Balance(currency: totalBalanceCurrency, money: totalBalanceMoney)
                
                let profit = WalletTypes.DTO.Staking.Profit(percent: profitPercent, total: totalBalance)
                
                return WalletTypes.DTO.Staking(profit: profit,
                                               balance: .init(total: .init(currency: .init(title: "USDB",
                                                                                           ticker: "USDB"),
                                                                           money: Money(45254, 2)),
                                                              available: .init(currency: .init(title: "USDB",
                                                                                               ticker: "USDB"),
                                                                               money: Money(45254, 2)),
                                                              inStaking: .init(currency: .init(title: "USDB",
                                                                                               ticker: "USDB"),
                                                                               money: Money(45254, 2))),
                                               lastPayouts: massTransferTrait,
                                               landing: nil)
            }
    }
}

// MARK: Assistants

private extension WalletInteractor {
    func leasing(isNeedUpdate: Bool) -> Observable<WalletTypes.DTO.Leasing> {
        let collection = authorizationInteractor
            .authorizedWallet()
            .flatMap(weak: self) { owner, wallet -> Observable<Leasing> in
                
                let transactions = owner.leasingInteractor.activeLeasingTransactionsSync(by: wallet.address)
                    .flatMap { (txs) -> Observable<[DomainLayer.DTO.SmartTransaction]> in
                        Observable.just(txs.resultIngoreError ?? [])
                    }
                
                let balance = owner.accountBalanceInteractor
                    .balances(by: wallet)
                    .map { $0.first { $0.asset.isWaves == true } }
                    .flatMap { balance -> Observable<DomainLayer.DTO.SmartAssetBalance> in
                        guard let balance = balance else { return Observable.empty() }
                        return Observable.just(balance)
                    }
                return Observable.zip(transactions, balance)
                    .map { transactions, balance -> Leasing in
                        Leasing(balance: balance,
                                transaction: transactions,
                                walletAddress: wallet.address)
                    }
            }
        
        return collection
            .map { leasing -> WalletTypes.DTO.Leasing in
                
                let precision = leasing.balance.asset.precision
                
                let incomingLeasingTxs = leasing.transaction.map { tx -> DomainLayer.DTO.SmartTransaction.Leasing? in
                    if case .incomingLeasing(let leasing) = tx.kind {
                        return leasing
                    } else {
                        return nil
                    }
                }
                .compactMap { $0 }
                
                let startedLeasingTxsBase = leasing.transaction.map { tx -> DomainLayer.DTO.SmartTransaction? in
                    if case .startedLeasing = tx.kind {
                        return tx
                    } else {
                        return nil
                    }
                }
                .compactMap { $0 }
                
                let startedLeasingTxs = startedLeasingTxsBase.map { tx -> DomainLayer.DTO.SmartTransaction.Leasing? in
                    if case .startedLeasing(let leasing) = tx.kind {
                        return leasing
                    } else {
                        return nil
                    }
                }
                .compactMap { $0 }
                
                let leaseAmount: Int64 = startedLeasingTxs
                    .reduce(0) { $0 + $1.balance.money.amount }
                let leaseInAmount: Int64 = incomingLeasingTxs
                    .reduce(0) { $0 + $1.balance.money.amount }
                
                let balance = leasing.balance
                let totalMoney: Money = .init(balance.totalBalance,
                                              precision)
                let avaliableMoney: Money = .init(balance.availableBalance,
                                                  precision)
                let leasedMoney: Money = .init(leaseAmount,
                                               precision)
                let leasedInMoney: Money = .init(leaseInAmount,
                                                 precision)
                
                let leasingBalance: WalletTypes
                    .DTO
                    .Leasing
                    .Balance = .init(totalMoney: totalMoney,
                                     avaliableMoney: avaliableMoney,
                                     leasedMoney: leasedMoney,
                                     leasedInMoney: leasedInMoney)
                
                return WalletTypes.DTO.Leasing(balance: leasingBalance,
                                               transactions: startedLeasingTxsBase)
            }
    }
    
    private typealias MassTransferTuple = (DataService.Response<[DataService.DTO.MassTransferTransaction]>,
                                           [DomainLayer.DTO.Asset],
                                           DataService.Query.MassTransferDataQuery)
    
    private static func prepareStartOf2020Year() -> Date? {
        var dateComponents = DateComponents()
        dateComponents.year = 2020
        dateComponents.month = 1
        dateComponents.day = 1
        
        return Calendar.current.date(from: dateComponents)
    }
    
    private func obtainMassTransfer() -> Observable<PayoutsHistoryState.MassTransferTrait> {
        let authorizedWallet = authorizationInteractor.authorizedWallet()
        
        return enviroment
            .developmentConfigs()
            .withLatestFrom(authorizedWallet, resultSelector: { ($0, $1) })
            .map { config, signedWallet -> DataService.Query.MassTransferDataQuery in
                let timeStart = WalletInteractor.prepareStartOf2020Year().map { "\($0.millisecondsSince1970)" }
                let timeEnd = "\(Date().millisecondsSince1970)"
                
                if let staking = config.staking.first {
                    let query = DataService.Query.MassTransferDataQuery(sender: staking.addressByPayoutsAnnualPercent,
                                                                        timeStart: timeStart,
                                                                        timeEnd: timeEnd,
                                                                        recipient: signedWallet.wallet.address,
                                                                        assetId: staking.neutrinoAssetId,
                                                                        after: nil,
                                                                        limit: nil)
                    return query
                } else {
                    let query = DataService.Query.MassTransferDataQuery(sender: "",
                                                                        timeStart: timeStart,
                                                                        timeEnd: timeEnd,
                                                                        recipient: "",
                                                                        assetId: "",
                                                                        after: nil,
                                                                        limit: nil)
                    return query
                }
            }
            .flatMap { [weak self] query -> Observable<MassTransferTuple> in
                guard let self = self else { return Observable.never() }
                
                let queryCache = Observable.just(query)
                let massTransferTransactions = self.massTransferRepository.obtainPayoutsHistory(query: query)
                
                let id = query.assetId ?? ""
                let accountAddress = query.recipient
                let asset = self.assetUseCase.assets(by: [id], accountAddress: accountAddress)
                
                return Observable.zip(massTransferTransactions, asset, queryCache)
            }
            .map { transactions, assets, query -> PayoutsHistoryState.MassTransferTrait in
                let isLastPage = transactions.isLastPage ?? true // дефолтное значение true чтоб не зацикливать загрузку если что
                let lastCursor = transactions.lastCursor
                let transactions = transactions.data
                let massTransferTransactions = PayoutsHistoryState.Core.MassTransferTransactions(isLastPage: isLastPage,
                                                                                                 lastCursor: lastCursor,
                                                                                                 transactions: transactions)
                
                return PayoutsHistoryState.MassTransferTrait(massTransferTransactions: massTransferTransactions,
                                                             walletAddress: query.recipient,
                                                             assetLogo: assets.first?.iconLogo,
                                                             precision: assets.first?.precision,
                                                             assetTicker: assets.first?.ticker)
            }
    }
}

extension WalletInteractor {
    private static func getTotalProfitPercent(transactions: [DataService.DTO.MassTransferTransaction], walletAddress: String)
        -> Double {
        // чо будет если будет меньше?
        // (ариф.сред. из 14 последних выплат * 365) / 100
        let profitPercentLastTransactions: [DataService.DTO.MassTransferTransaction] = transactions.suffix(14)
        let finalCountLastProfit = profitPercentLastTransactions.count
        
        let allProfit = getTotalProfit(transactions: profitPercentLastTransactions, walletAddress: walletAddress)
        
        let average = allProfit / Double(finalCountLastProfit)
        
        return (average * 365) / 100
    }
    
    private static func getTotalProfit(transactions: [DataService.DTO.MassTransferTransaction], walletAddress: String) -> Double {
        transactions.map {
            $0.transfers
                .filter { $0.recipient == walletAddress }
                .reduce(0) { $0 + $1.amount }
        }
        .reduce(0, { $0 + $1 })
    }
}
