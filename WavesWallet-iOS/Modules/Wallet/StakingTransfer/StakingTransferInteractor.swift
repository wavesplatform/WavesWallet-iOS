//
//  StakingTransferInteractor.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 03.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Extensions
import DomainLayer
import WavesSDK

private enum Constanst {
    static let transferFee: Int64 = 500000
    static let lockNeutrinoFunctionName = "lockNeutrino"
    static let unlockNeutrinoFunctionName = "unlockNeutrino"
}

// TODO: Support smart fee
final class StakingTransferInteractor {
    
    let accountBalanceUseCase: AccountBalanceUseCaseProtocol = UseCasesFactory.instance.accountBalance
    let assetsUseCase: AssetsUseCaseProtocol = UseCasesFactory.instance.assets
    let transactionUseCase: TransactionsUseCaseProtocol = UseCasesFactory.instance.transactions
    let authorizationUseCase: AuthorizationUseCaseProtocol = UseCasesFactory.instance.authorization
    let developmentConfigsRepository: DevelopmentConfigsRepositoryProtocol = UseCasesFactory.instance.repositories.developmentConfigsRepository
    let adCashDepositsUseCase: AdCashDepositsUseCaseProtocol = UseCasesFactory.instance.adCashDepositsUseCase
    
    let stakingBalanceService: StakingBalanceService = UseCasesFactory.instance.repositories.stakingBalanceService
    
    func withdraw(assetId: String) -> Observable<StakingTransfer.DTO.Data.Transfer> {
        
        return self.authorizationUseCase
            .authorizedWallet()
            .flatMap { [weak self] wallet -> Observable<StakingTransfer.DTO.Data.Transfer> in
                
                guard let self = self else { return Observable.never() }
                
                let depositeStakingBalance = self.stakingBalanceService
                    .getDepositeStakingBalance().map { $0.value }
                
                let wavesBalance = self.accountBalanceUseCase.balance(by: WavesSDKConstants.wavesAssetId,
                                                                 wallet: wallet)
                
                let asset = self.assetsUseCase.assets(by: [assetId],
                                                      accountAddress: wallet.address)
                
                return Observable.zip(depositeStakingBalance, wavesBalance, asset)
                    .flatMap { depositeStakingBalance, wavesBalance, assets -> Observable<StakingTransfer.DTO.Data.Transfer> in
                                                                        
                        guard let asset = assets.first(where: { $0.id == assetId }) else { return Observable.error(NetworkError.notFound) }
                        let wavesAsset = wavesBalance.asset
                        
                        let balance = asset.balance(depositeStakingBalance)
                        let fee: DomainLayer.DTO.Balance = wavesAsset.balance(Constanst.transferFee)
                        
                        let avaliableBalanceForFee = wavesBalance.availableBalance()
                        
                        let deposit: StakingTransfer.DTO.Data.Transfer = .init(asset: asset,
                                                                               balance: balance,
                                                                               transactionFeeBalance: fee,
                                                                               avaliableBalanceForFee: avaliableBalanceForFee)
                        
                        
                        return Observable.just(deposit)
                }
        }
        
    }
    
    func deposit(assetId: String) -> Observable<StakingTransfer.DTO.Data.Transfer> {
        
        return self.authorizationUseCase
            .authorizedWallet()
            .flatMap { [weak self] wallet -> Observable<StakingTransfer.DTO.Data.Transfer> in
                
                guard let self = self else { return Observable.never() }
                
                let balanceNetrino = self.accountBalanceUseCase
                    .balance(by: assetId,
                             wallet: wallet)
                    
                let waveBalance = self.accountBalanceUseCase.balance(by: WavesSDKConstants.wavesAssetId,
                                                                     wallet: wallet)
                    
                return Observable.zip(balanceNetrino, waveBalance)
                    .flatMap { balanceNetrino, wavesBalance -> Observable<StakingTransfer.DTO.Data.Transfer> in
                        
                        let assetNetrino = balanceNetrino.asset
                        let assetWaves = wavesBalance.asset
                        
                        let balanceNetrino: DomainLayer.DTO.Balance = balanceNetrino.availableBalance()
                        
                        let avaliableBalanceForFee = wavesBalance.availableBalance()
                        
                        let fee: DomainLayer.DTO.Balance = assetWaves.balance(Constanst.transferFee)
                        
                        let deposit: StakingTransfer.DTO.Data.Transfer = .init(asset: assetNetrino,
                                                                               balance: balanceNetrino,
                                                                               transactionFeeBalance: fee,
                                                                               avaliableBalanceForFee: avaliableBalanceForFee)
                        
                        
                        return Observable.just(deposit)
                }
        }
    }
    
    func card(assetId: String) -> Observable<StakingTransfer.DTO.Data.Card> {
        
        let auth = self.authorizationUseCase.authorizedWallet()
        
        return auth.flatMap { [weak self] (wallet) -> Observable<StakingTransfer.DTO.Data.Card> in
        
            guard let self = self else { return Observable.never() }
            
            let assets = self.assetsUseCase.assets(by: [assetId],
                                                  accountAddress: wallet.address)
            
            let requirementsOrder = self
                .adCashDepositsUseCase
                .requirementsOrder(assetId: assetId)
            
            let developmentConfigs = self
                .developmentConfigsRepository
                .developmentConfigs()
                        
            return Observable.zip(assets, requirementsOrder, developmentConfigs)
                .flatMap({ (assets, requirementsOrder, developmentConfigs) -> Observable<StakingTransfer.DTO.Data.Card> in
                    
                    guard let asset = assets.first(where: { $0.id == assetId }) else { return Observable.error(NetworkError.notFound) }
                                        
                    let gatewayMinFee = developmentConfigs.gatewayMinFee[assetId]?["usd"]
                    let rate = Decimal(gatewayMinFee?.rate ?? 1)
                    let flat = Decimal(gatewayMinFee?.flat ?? 0)
                    let amountMin = Decimal(requirementsOrder.amountMin.amount)
                                        
                    let minAmountBase = (amountMin * rate + flat).int64Value
                                                            
                    let minAmount = asset.balance(minAmountBase)
                        
                    let maxAmount = asset
                        .balance(requirementsOrder.amountMax.amount)
                    
                    let card = StakingTransfer.DTO.Data.Card(asset: asset,
                                                             minAmount: minAmount,
                                                             maxAmount: maxAmount)
                
                        
                    return Observable.just(card)
                })
        }
    }
    
    func sendCard(amount: Money, assetId: String) -> Observable<URL> {
        
        return self.adCashDepositsUseCase
            .createOrder(assetId: assetId,
                         amount: amount)
            .map { $0.url }
    }
    
    func sendDeposit(amount: Money, assetId: String) -> Observable<DomainLayer.DTO.SmartTransaction> {
        
        return sendInvokeTrasnfer(amount: amount,
                                  assetId: assetId,
                                  isDeposit: true)
    }
    
    func sendWithdraw(amount: Money, assetId: String) -> Observable<DomainLayer.DTO.SmartTransaction> {
        
        return sendInvokeTrasnfer(amount: amount,
                                  assetId: assetId,
                                  isDeposit: false)
    }
            
    private func sendInvokeTrasnfer(amount: Money, assetId: String, isDeposit: Bool) -> Observable<DomainLayer.DTO.SmartTransaction> {
        
        let developmentConfigs = self.developmentConfigsRepository.developmentConfigs()
        let authorizedWallet = self.authorizationUseCase.authorizedWallet()
        
        return Observable.zip(developmentConfigs, authorizedWallet)
            .flatMap { [weak self] configs, wallet -> Observable<DomainLayer.DTO.SmartTransaction> in
                
                guard let self = self else { return Observable.never() }
                
                
                guard let staking = configs.staking.first(where: { $0.neutrinoAssetId == assetId }) else { return Observable.error(NetworkError.notFound) }
                                                
                let call: InvokeScriptTransactionSender.Call = {
                
                    var args: [InvokeScriptTransactionSender.Arg] = .init()
                    var functionName: String = ""
                    
                    if isDeposit {
                        functionName = Constanst.lockNeutrinoFunctionName
                    } else {
                        functionName = Constanst.unlockNeutrinoFunctionName
                        args.append(.init(value: .integer(amount.amount)))
                        args.append(.init(value: .string(assetId)))
                    }
                    
                    return  .init(function: functionName,
                                  args: args)
                }()
                
                let payments: [InvokeScriptTransactionSender.Payment] = {
                   
                    if isDeposit {
                        return [.init(amount: amount.amount,
                                      assetId: assetId)]
                    } else {
                        return []
                    }
                }()
                                                
                let sender: InvokeScriptTransactionSender = .init(fee: Constanst.transferFee,
                                                                  feeAssetId: WavesSDKConstants.wavesAssetId,
                                                                  dApp: staking.addressStakingContract,
                                                                  call: call,
                                                                  payment: payments)
                
                let specifications: TransactionSenderSpecifications = .invokeScript(sender)
                
                return self.transactionUseCase
                    .send(by: specifications,
                          wallet: wallet)
        }
    }
}


//TODO: Move
extension DomainLayer.DTO.Asset {
    
    func balance(_ balance: Int64) -> DomainLayer.DTO.Balance {
        return .init(currency: .init(title: self.name,
                                     
                                     ticker: self.ticker),
                     money: .init(balance,
                                  self.precision))
    }
}

extension Money {
    
    enum Percent: Decimal {
        case p15 = 15
        case p25 = 25
        case p50 = 50
        case p75 = 75
        case p100 = 100
    }
    
    func calculatePercent(_ percent: Percent) -> Money {
        let value = decimalValue * (percent.rawValue / 100.0)
        
        return Money(value: value, decimals)
    }
}

extension DomainLayer.DTO.SmartAssetBalance {
    
    func availableBalance() -> DomainLayer.DTO.Balance {
        return self.asset.balance(self.availableBalance)
    }
    
}

extension StakingTransfer.DTO.AssistanceButton {
    
    var percent: Money.Percent {
        switch self {
        case .percent100:
            return .p100
            
        case .percent75:
            return .p75
            
        case .percent50:
            return .p50
            
        case .percent25:
            return .p25
            
        case .max:
            return .p100
        }
    }
}
