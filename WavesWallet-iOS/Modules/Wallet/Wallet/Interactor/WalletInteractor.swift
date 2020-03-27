//
//  WalletInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 16/07/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DataLayer
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
    
    private let stakingBalanceService: StakingBalanceService
    
    private let disposeBag = DisposeBag()
    
    init(enviroment: DevelopmentConfigsRepositoryProtocol,
         massTransferRepository: MassTransferRepositoryProtocol,
         assetUseCase: AssetsUseCaseProtocol,
         stakingBalanceService: StakingBalanceService,
         authorizationInteractor: AuthorizationUseCaseProtocol,
         accountBalanceInteractor: AccountBalanceUseCaseProtocol,
         accountSettingsRepository: AccountSettingsRepositoryProtocol,
         applicationVersionUseCase: ApplicationVersionUseCaseProtocol,
         leasingInteractor: TransactionsUseCaseProtocol,
         walletsRepository: WalletsRepositoryProtocol) {
        self.enviroment = enviroment
        self.massTransferRepository = massTransferRepository
        self.assetUseCase = assetUseCase
        self.stakingBalanceService = stakingBalanceService
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

        Observable
            .zip(enviroment.developmentConfigs(),
                 obtainYearPercent(),
                 obtainTotalProfit(),
                 obtainLastPayoutsTransactions(),
                 stakingBalanceService.totalStakingBalance())
            
            .map { config, yearPercentMassTransfer, totalProfitMassTransfer, lastPayoutsTransactions, stakingBalance -> WalletTypes.DTO.Staking in
                
                let walletAddress = lastPayoutsTransactions.walletAddress
                
                let profitPercent = WalletInteractor.getTotalProfitPercent(transactions: yearPercentMassTransfer.data,
                                                                           walletAddress: config.staking.first?.addressByCalculateProfit ?? "")
                
                let totalProfitTransactions = totalProfitMassTransfer.massTransferTransactions.transactions
                let totalProfit = WalletInteractor.getTotalProfit(transactions: totalProfitTransactions,
                                                                  walletAddress: walletAddress)
                
                let totalBalanceCurrency = DomainLayer.DTO.Balance.Currency(title: "", ticker: totalProfitMassTransfer.assetTicker)
                let totalBalanceMoney = Money(value: Decimal(totalProfit), totalProfitMassTransfer.precision ?? 0)
                
                let totalBalance = DomainLayer.DTO.Balance(currency: totalBalanceCurrency, money: totalBalanceMoney)
                
                let profit = WalletTypes.DTO.Staking.Profit(percent: profitPercent, total: totalBalance)
                
                let stakingCurrencyBalance = DomainLayer.DTO.Balance.Currency(title: "", ticker: stakingBalance.assetTicker)
                
                let totalStakingBalanceMoney = Money(stakingBalance.totalBalance, stakingBalance.precision)
                let totalStakingBalance = DomainLayer.DTO.Balance(currency: stakingCurrencyBalance, money: totalStakingBalanceMoney)
                
                let availableStakingBalanceMoney = Money(stakingBalance.availbleBalance, stakingBalance.precision)
                let availableStakingBalance = DomainLayer.DTO.Balance(currency: stakingCurrencyBalance,
                                                                      money: availableStakingBalanceMoney)
                
                let inStakingBalanceMoney = Money(stakingBalance.depositeBalance, stakingBalance.precision)
                let inStakingBalance = DomainLayer.DTO.Balance(currency: stakingCurrencyBalance, money: inStakingBalanceMoney)
                
                let balance = WalletTypes.DTO.Staking.Balance(total: totalStakingBalance,
                                                              available: availableStakingBalance,
                                                              inStaking: inStakingBalance)
                
                let showLandingIfNeeded = WalletLandingSetting.value
                
                let minimumDeposit = DomainLayer.DTO.Balance(currency: totalBalanceCurrency,
                                                             money: Money(10000, stakingBalance.precision))
                let landing = WalletTypes.DTO.Staking.Landing(percent: profitPercent,
                                                              minimumDeposit: minimumDeposit)
                
                let assetId = config.staking.first?.neutrinoAssetId ?? ""
                
                let neutrinoAsset = DomainLayer.DTO.Asset.init(id: assetId, gatewayId: "", wavesId: "", name: "", precision: 0, description: "", height: 0, timestamp: Date(), sender: "", quantity: 0, ticker: "", isReusable: true, isSpam: true, isFiat: true, isGeneral: true, isMyWavesToken: true, isWavesToken: true, isGateway: true, isWaves: true, modified: Date(), addressRegEx: "", iconLogoUrl: "", hasScript: false, minSponsoredFee: 0, gatewayType: "")
                
                return WalletTypes.DTO.Staking(profit: profit,
                                               balance: balance,
                                               lastPayouts: lastPayoutsTransactions,
                                               neutrinoAsset: neutrinoAsset,
                                               landing: showLandingIfNeeded ? landing : nil)
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
    
    /// Общий профит в процентах за год
    /// Расчитывается по следующей формуле:  % = (арифметическое из транзикций) * количество транзакций / 100
    /// Если транзакций меньше чем 14 берем количество того сколько есть (про ноль пока узнают)
    private func obtainYearPercent() -> Observable<DataService.Response<[DataService.DTO.MassTransferTransaction]>> {
        enviroment
            .developmentConfigs()
            .map { config -> DataService.Query.MassTransferDataQuery in
                
                let calendar = Calendar.current
                let dateNow = Date()
                
                let startDate = calendar.date(byAdding: .year, value: -1, to: dateNow).map { "\($0.millisecondsSince1970)" }
                let endDate = "\(dateNow.millisecondsSince1970)"
                
                let query: DataService.Query.MassTransferDataQuery
                
                if let staking = config.staking.first {
                    query = DataService.Query.MassTransferDataQuery(sender: staking.addressByPayoutsAnnualPercent,
                                                                    timeStart: startDate,
                                                                    timeEnd: endDate,
                                                                    recipient: staking.addressByCalculateProfit,
                                                                    assetId: staking.neutrinoAssetId,
                                                                    after: nil,
                                                                    limit: nil)
                } else {
                    // кейс если нет стакинга нужно как-то обработать
                    query = DataService.Query.MassTransferDataQuery(sender: "",
                                                                    timeStart: nil,
                                                                    timeEnd: nil,
                                                                    recipient: "",
                                                                    assetId: "",
                                                                    after: nil,
                                                                    limit: nil)
                }
                
                return query
            }
            .flatMap { [weak self] query -> Observable<DataService.Response<[DataService.DTO.MassTransferTransaction]>> in
                guard let strongSelf = self else { return Observable.never() }
                return strongSelf.massTransferRepository.obtainPayoutsHistory(query: query)
            }
    }
    
    /// Общий доход (Синяя карточка)
    private func obtainTotalProfit() -> Observable<PayoutsHistoryState.MassTransferTrait> {
        let timeStart = WalletInteractor.prepareStartOf2020Year().map { "\($0.millisecondsSince1970)" }
        let timeEnd = "\(Date().millisecondsSince1970)"
        
        return performLastPayoutsTransactionRequest(timeStart: timeStart, timeEnd: timeEnd)
    }
    
    private func obtainLastPayoutsTransactions() -> Observable<PayoutsHistoryState.MassTransferTrait> {
        performLastPayoutsTransactionRequest(timeStart: nil, timeEnd: nil)
    }
    
    private func performLastPayoutsTransactionRequest(timeStart: String?, timeEnd: String?)
        -> Observable<PayoutsHistoryState.MassTransferTrait> {
        let authorizedWallet = authorizationInteractor.authorizedWallet()
        
        return enviroment
            .developmentConfigs()
            .withLatestFrom(authorizedWallet, resultSelector: { ($0, $1) })
            .map { config, signedWallet -> DataService.Query.MassTransferDataQuery in
                
                // в чем разница между authorizedWallet.wallet.address и authorizedWallet.
                //
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
    private static func getTotalProfitPercent(transactions: [DataService.DTO.MassTransferTransaction],
                                              walletAddress: String) -> Double {
        // (ариф.сред. из транзакций) * 365
        let finalCountLastProfit = transactions.count
        
        let allProfit = getTotalProfit(transactions: transactions, walletAddress: walletAddress)
        
        let average = allProfit / Double(finalCountLastProfit)
        
        return (average * 365)
    }
    
    private static func getTotalProfit(transactions: [DataService.DTO.MassTransferTransaction],
                                       walletAddress: String) -> Double {
        transactions.map {
            $0.transfers
                .filter { $0.recipient == walletAddress }
                .reduce(0) { $0 + $1.amount }
        }
        .reduce(0, { $0 + $1 })
    }
}
