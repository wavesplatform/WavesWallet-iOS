//
//  WalletInteractorProtocol.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 16/07/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import WavesSDKExtensions
import DomainLayer
import Extensions

private struct Leasing {
    let balance: DomainLayer.DTO.SmartAssetBalance
    let transaction: [DomainLayer.DTO.SmartTransaction]
    let walletAddress: String
}

final class WalletInteractor: WalletInteractorProtocol {
  
    private let authorizationInteractor: AuthorizationUseCaseProtocol = UseCasesFactory.instance.authorization
    private let accountBalanceInteractor: AccountBalanceUseCaseProtocol = UseCasesFactory.instance.accountBalance
    private let accountSettingsRepository: AccountSettingsRepositoryProtocol = UseCasesFactory.instance.repositories.accountSettingsRepository
    private let applicationVersionUseCase: ApplicationVersionUseCase = UseCasesFactory.instance.applicationVersionUseCase
    
    private let leasingInteractor: TransactionsUseCaseProtocol = UseCasesFactory.instance.transactions
    
    private let disposeBag: DisposeBag = DisposeBag()
    private let walletsRepository: WalletsRepositoryProtocol = UseCasesFactory.instance.repositories.walletsRepositoryLocal

    func isHasAppUpdate() -> Observable<Bool> {
        return applicationVersionUseCase.isHasNewVersion()
    }
    
    func setCleanWalletBanner() -> Observable<Bool> {
        return authorizationInteractor.authorizedWallet()
            .flatMap({ [weak self] (signedWallet) -> Observable<Bool> in
                guard let self = self else { return Observable.empty() }
                return self.walletsRepository.wallet(by: signedWallet.wallet.publicKey)
                    .flatMap{  [weak self] (wallet) -> Observable<Bool> in
                        guard let self = self else { return Observable.empty() }

                        var newWallet = wallet
                        newWallet.isNeedShowWalletCleanBanner = false
                        return self.walletsRepository.saveWallet(newWallet)
                            .flatMap({ (_) -> Observable<Bool> in
                                return Observable.just(true)
                            })
                    }
            })
    }
    
    func isShowCleanWalletBanner() -> Observable<Bool> {
        return authorizationInteractor.authorizedWallet()
            .map { $0.wallet.isNeedShowWalletCleanBanner }
    }
    
    func assets() -> Observable<[DomainLayer.DTO.SmartAssetBalance]> {
        return authorizationInteractor
            .authorizedWallet()
            .flatMap({ [weak self] wallet -> Observable<[DomainLayer.DTO.SmartAssetBalance]> in
                guard let self = self else { return Observable.never() }
                
                let assets = self.accountBalanceInteractor.balances(by: wallet)
                let settings = self.accountSettingsRepository.accountSettings(accountAddress: wallet.address)
                    
                return Observable.zip(assets, settings)
                    .map({ (assets, settings) -> [DomainLayer.DTO.SmartAssetBalance] in
                        
                        if let settings = settings, settings.isEnabledSpam {
                            return assets.filter { $0.asset.isSpam == false }
                        }

                        return assets
                    })
            })
    }

    func leasing() -> Observable<WalletTypes.DTO.Leasing> {
        return Observable.merge(leasing(isNeedUpdate: true))
    }
}

// MARK: Assistants

fileprivate extension WalletInteractor {

    func leasing(isNeedUpdate: Bool) -> Observable<WalletTypes.DTO.Leasing> {

        let collection = authorizationInteractor
            .authorizedWallet()
            .flatMap(weak: self) { owner, wallet -> Observable<Leasing> in
                
                let transactions = owner.leasingInteractor.activeLeasingTransactionsSync(by: wallet.address)
                    .flatMap { (txs) -> Observable<[DomainLayer.DTO.SmartTransaction]> in
                        return Observable.just(txs.resultIngoreError ?? [])
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
}
