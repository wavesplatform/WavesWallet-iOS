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
    let transaction: [SmartTransaction]
    let walletAddress: String
}

final class InvestmentInteractor: InvestmentInteractorProtocol {
    private let enviroment: DevelopmentConfigsRepositoryProtocol
    private let massTransferRepository: MassTransferRepositoryProtocol
    private let assetsRepository: AssetsRepositoryProtocol

    private let authorizationInteractor: AuthorizationUseCaseProtocol
    private let accountBalanceInteractor: AccountBalanceUseCaseProtocol
    private let accountSettingsRepository: AccountSettingsRepositoryProtocol
    private let serverEnvironmentUseCase: ServerEnvironmentRepository

    private let leasingUseCase: TransactionsUseCaseProtocol
    private let stakingBalanceService: StakingBalanceService

    private let disposeBag = DisposeBag()

    init(enviroment: DevelopmentConfigsRepositoryProtocol,
         massTransferRepository: MassTransferRepositoryProtocol,
         assetsRepository: AssetsRepositoryProtocol,
         stakingBalanceService: StakingBalanceService,
         authorizationInteractor: AuthorizationUseCaseProtocol,
         accountBalanceInteractor: AccountBalanceUseCaseProtocol,
         accountSettingsRepository: AccountSettingsRepositoryProtocol,
         leasingInteractor: TransactionsUseCaseProtocol,
         serverEnvironmentUseCase: ServerEnvironmentRepository) {
        self.enviroment = enviroment
        self.massTransferRepository = massTransferRepository
        self.assetsRepository = assetsRepository
        self.stakingBalanceService = stakingBalanceService
        self.authorizationInteractor = authorizationInteractor
        self.accountBalanceInteractor = accountBalanceInteractor
        self.accountSettingsRepository = accountSettingsRepository
        self.leasingUseCase = leasingInteractor
        self.serverEnvironmentUseCase = serverEnvironmentUseCase
    }

    func leasing() -> Observable<InvestmentLeasingVM> {
        return Observable.merge(leasing(isNeedUpdate: true))
    }

    func staking() -> Observable<InvestmentStakingVM> {
        let obtainNeutrinoAsset = Observable.zip(authorizationInteractor.authorizedWallet(),
                                                 enviroment.developmentConfigs())
            .flatMap { [weak self] signedWallet, config -> Observable<(assets: [Asset], accountAddress: String)> in
                guard let strongSelf = self else { return Observable.never() }

                let neutrinoId = config.staking.first?.neutrinoAssetId ?? ""
                let addressWallet = signedWallet.wallet.address
                return strongSelf
                    .assetsRepository
                    .assets(ids: [neutrinoId], accountAddress: addressWallet)
                    .map { $0.compactMap { $0 } }
                    .map { (assets: $0, accountAddress: addressWallet) }
            }

        return Observable
            .zip(enviroment.developmentConfigs(),
                 obtainProfitInPercents(),
                 obtainTotalProfit(),
                 obtainLastPayoutsTransactions(),
                 stakingBalanceService.totalStakingBalance(),
                 obtainNeutrinoAsset)
            .map { config, yearPercentMassTransfer, totalProfitMassTransfer, lastPayoutsTransactions, stakingBalance, neutrinoAsset -> InvestmentStakingVM in

                let walletAddress = lastPayoutsTransactions.walletAddress

                let profitPercent = InvestmentInteractor.getTotalProfitPercent(transactions: yearPercentMassTransfer.data,
                                                                               walletAddress: config.staking.first?
                                                                                   .addressByCalculateProfit ?? "")

                let totalProfitTransactions = totalProfitMassTransfer.massTransferTransactions.transactions
                let totalProfit = InvestmentInteractor.getTotalProfit(transactions: totalProfitTransactions,
                                                                      walletAddress: walletAddress)

                let totalBalanceCurrency = DomainLayer.DTO.Balance
                    .Currency(title: "", ticker: totalProfitMassTransfer.assetTicker)
                let totalBalanceMoney = Money(value: Decimal(totalProfit), totalProfitMassTransfer.precision ?? 0)

                let totalBalance = DomainLayer.DTO.Balance(currency: totalBalanceCurrency, money: totalBalanceMoney)

                let profit = InvestmentStakingVM.Profit(percent: profitPercent, total: totalBalance)

                let stakingCurrencyBalance = DomainLayer.DTO.Balance.Currency(title: "", ticker: stakingBalance.assetTicker)

                let totalStakingBalanceMoney = Money(stakingBalance.totalBalance, stakingBalance.precision)
                let totalStakingBalance = DomainLayer.DTO
                    .Balance(currency: stakingCurrencyBalance, money: totalStakingBalanceMoney)

                let availableStakingBalanceMoney = Money(stakingBalance.availbleBalance, stakingBalance.precision)
                let availableStakingBalance = DomainLayer.DTO.Balance(currency: stakingCurrencyBalance,
                                                                      money: availableStakingBalanceMoney)

                let inStakingBalanceMoney = Money(stakingBalance.depositeBalance, stakingBalance.precision)
                let inStakingBalance = DomainLayer.DTO.Balance(currency: stakingCurrencyBalance, money: inStakingBalanceMoney)

                let balance = InvestmentStakingVM.Balance(total: totalStakingBalance,
                                                          available: availableStakingBalance,
                                                          inStaking: inStakingBalance)

                let isShowedLanding = WalletLandingSetting.value[neutrinoAsset.accountAddress] ?? false

                let showLandingIfNeeded = isShowedLanding == false

                let minimumDeposit = DomainLayer.DTO.Balance(currency: totalBalanceCurrency,
                                                             money: Money(10000, stakingBalance.precision))
                let landing = InvestmentStakingVM.Landing(percent: profitPercent,
                                                          minimumDeposit: minimumDeposit)

                return InvestmentStakingVM(accountAddress: neutrinoAsset.accountAddress,
                                           profit: profit,
                                           balance: balance,
                                           lastPayouts: lastPayoutsTransactions,
                                           neutrinoAsset: neutrinoAsset.assets.first,
                                           landing: showLandingIfNeeded ? landing : nil)
            }
    }
}

// MARK: Assistants

private extension InvestmentInteractor {
    func leasing(isNeedUpdate _: Bool) -> Observable<InvestmentLeasingVM> {
        let collection = authorizationInteractor
            .authorizedWallet()
            .flatMap(weak: self) { owner, wallet -> Observable<Leasing> in

                let transactions = owner.leasingUseCase.activeLeasingTransactionsSync(by: wallet.address)
                    .flatMap { (txs) -> Observable<[SmartTransaction]> in
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
            .map { leasing -> InvestmentLeasingVM in

                let precision = leasing.balance.asset.precision

                let incomingLeasingTxs = leasing.transaction.map { tx -> SmartTransaction.Leasing? in
                    if case let .incomingLeasing(leasing) = tx.kind {
                        return leasing
                    } else {
                        return nil
                    }
                }
                .compactMap { $0 }

                let startedLeasingTxsBase = leasing.transaction.map { tx -> SmartTransaction? in
                    if case .startedLeasing = tx.kind {
                        return tx
                    } else {
                        return nil
                    }
                }
                .compactMap { $0 }

                let startedLeasingTxs = startedLeasingTxsBase.map { tx -> SmartTransaction.Leasing? in
                    if case let .startedLeasing(leasing) = tx.kind {
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
                let totalMoney: Money = .init(balance.totalBalance - balance.inOrderBalance,
                                              precision)
                let avaliableMoney: Money = .init(balance.availableBalance,
                                                  precision)
                let leasedMoney: Money = .init(leaseAmount,
                                               precision)
                let leasedInMoney: Money = .init(leaseInAmount,
                                                 precision)

                let leasingBalance = InvestmentLeasingVM.Balance(totalMoney: totalMoney,
                                                                 avaliableMoney: avaliableMoney,
                                                                 leasedMoney: leasedMoney,
                                                                 leasedInMoney: leasedInMoney)

                return InvestmentLeasingVM(balance: leasingBalance,
                                           transactions: startedLeasingTxsBase)
            }
    }

    private typealias MassTransferTuple = (DataService.Response<[DataService.DTO.MassTransferTransaction]>,
                                           [Asset],
                                           DataService.Query.MassTransferDataQuery)

    private static func prepareStartOf2020Year() -> Date? {
        var dateComponents = DateComponents()
        dateComponents.year = 2020
        dateComponents.month = 1
        dateComponents.day = 1

        return Calendar.current.date(from: dateComponents)
    }

    /// Средний профит за последние 14 транзакций
    /// Расчитывается по следующей формуле:  % = (арифметическое из транзикций) * количество транзакций / 100
    private func obtainProfitInPercents() -> Observable<DataService.Response<[DataService.DTO.MassTransferTransaction]>> {
        enviroment
            .developmentConfigs()
            .map { config -> DataService.Query.MassTransferDataQuery in

                let calendar = Calendar.current
                let dateNow = Date()

                let startDate = calendar.date(byAdding: .day, value: -14, to: dateNow).map { "\($0.millisecondsSince1970)" }
                let endDate = "\(dateNow.millisecondsSince1970)"

                let query: DataService.Query.MassTransferDataQuery

                if let staking = config.staking.first {
                    query = DataService.Query.MassTransferDataQuery(senders: staking.addressesByPayoutsAnnualPercent,
                                                                    timeStart: startDate,
                                                                    timeEnd: endDate,
                                                                    recipient: staking.addressByCalculateProfit,
                                                                    assetId: staking.neutrinoAssetId,
                                                                    after: nil,
                                                                    limit: nil)
                } else {
                    // кейс если нет стакинга нужно как-то обработать
                    query = DataService.Query.MassTransferDataQuery(senders: [],
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
                guard let self = self else { return Observable.never() }

                return self.serverEnvironmentUseCase
                    .serverEnvironment()
                    .flatMap { [weak self] serverEnvironment -> Observable<DataService.Response<[DataService.DTO.MassTransferTransaction]>> in

                        guard let self = self else { return Observable.never() }

                        return self.massTransferRepository
                            .obtainPayoutsHistory(serverEnvironment: serverEnvironment,
                                                  query: query)
                    }
            }
    }

    /// Общий доход (Синяя карточка)
    private func obtainTotalProfit() -> Observable<PayoutsHistoryState.MassTransferTrait> {
        let timeStart = InvestmentInteractor.prepareStartOf2020Year().map { "\($0.millisecondsSince1970)" }
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
                    let query = DataService.Query.MassTransferDataQuery(senders: staking.addressesByPayoutsAnnualPercent,
                                                                        timeStart: timeStart,
                                                                        timeEnd: timeEnd,
                                                                        recipient: signedWallet.wallet.address,
                                                                        assetId: staking.neutrinoAssetId,
                                                                        after: nil,
                                                                        limit: nil)
                    return query
                } else {
                    let query = DataService.Query.MassTransferDataQuery(senders: nil,
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

                let massTransferTransactions = self
                    .serverEnvironmentUseCase
                    .serverEnvironment()
                    .flatMap { [weak self] serverEnvironment -> Observable<DataService.Response<[DataService.DTO.MassTransferTransaction]>> in
                        guard let self = self else { return Observable.never() }
                        return self.massTransferRepository.obtainPayoutsHistory(serverEnvironment: serverEnvironment,
                                                                                query: query)
                    }

                let id = query.assetId ?? ""
                let accountAddress = query.recipient
                let asset = self.assetsRepository.assets(ids: [id], accountAddress: accountAddress)
                    .map { $0.compactMap { $0 } }

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

extension InvestmentInteractor {
    private static func getTotalProfitPercent(transactions: [DataService.DTO.MassTransferTransaction],
                                              walletAddress: String) -> Double {
        // (ариф.сред. из транзакций) * 365
        let finalCountLastProfit = transactions.reduce(0) { $0 + $1.transfers.filter { $0.recipient == walletAddress }.count }

        let allProfit = getTotalProfit(transactions: transactions, walletAddress: walletAddress)

        let average = allProfit / Double(finalCountLastProfit)

        return average * 365
    }

    private static func getTotalProfit(transactions: [DataService.DTO.MassTransferTransaction],
                                       walletAddress: String) -> Double {
        transactions.map {
            $0.transfers
                .filter { $0.recipient == walletAddress }
                .reduce(0) { $0 + $1.amount }
        }
        .reduce(0) { $0 + $1 }
    }
}
