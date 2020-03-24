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


//{
//    'senderPublicKey': {publicKey},
//    'fee': {fee},
//    'type': 16,
//    'version': 1,
//    'call': {
//        'function': 'lockNeutrino',
//        args: []
//    },
//    'dApp': 'address_stacking_contract',
//    'sender':  {address},
//    'feeAssetId': null,
//    'payment': [
//        {
//            'amount': {amount},
//            'assetId': 'neutrino_asset_id',
//        }
//    ]
//}

private enum Constanst {
    static let transferFee: Int64 = 500000
    static let lockNeutrinoFunctionName = "lockNeutrino"
    static let unlockNeutrinoFunctionName = "unlockNeutrino"
}

final class StakingTransferInteractor {
    
    let accountBalanceUseCase: AccountBalanceUseCaseProtocol = UseCasesFactory.instance.accountBalance
    let assetsUseCase: AssetsUseCaseProtocol = UseCasesFactory.instance.assets
    let transactionUseCase: TransactionsUseCaseProtocol = UseCasesFactory.instance.transactions
    let authorizationUseCase: AuthorizationUseCaseProtocol = UseCasesFactory.instance.authorization
    let developmentConfigsRepository: DevelopmentConfigsRepositoryProtocol = UseCasesFactory.instance.repositories.developmentConfigsRepository
    
//    init(accountBalanceUseCase: AccountBalanceUseCaseProtocol,
//         transactionUseCase: TransactionsUseCaseProtocol,
//         authorizationUseCase: AuthorizationUseCaseProtocol) {
//        
//        self.authorizationUseCase = authorizationUseCase
//        self.accountBalanceUseCase = accountBalanceUseCase
//        self.transactionUseCase = transactionUseCase
//    }
    
    
    func withdraw(assetId: String) -> Observable<StakingTransfer.DTO.Data.Transfer> {
        
        return self.authorizationUseCase
            .authorizedWallet()
            .flatMap { [weak self] wallet -> Observable<StakingTransfer.DTO.Data.Transfer> in
                
                guard let self = self else { return Observable.never() }
                
                let balance = self.stakingBalance()
                let asset = self.assetsUseCase.assets(by: [assetId],
                                                      accountAddress: wallet.address)
                
                return Observable.zip(balance, asset)
                    .flatMap { balance, assets -> Observable<StakingTransfer.DTO.Data.Transfer> in
                                        
                        guard let asset = assets.first else { return Observable.never() }
                        
                        let fee: DomainLayer.DTO.Balance = asset.balance(Constanst.transferFee)
                        
                        let deposit: StakingTransfer.DTO.Data.Transfer = .init(asset: asset,
                                                                               balance: balance,
                                                                               transactionFeeBalance: fee)
                        
                        
                        return Observable.just(deposit)
                }
        }

    }
    
    func deposit(assetId: String) -> Observable<StakingTransfer.DTO.Data.Transfer> {
        
        return self.authorizationUseCase
            .authorizedWallet()
            .flatMap { [weak self] wallet -> Observable<StakingTransfer.DTO.Data.Transfer> in
                
                guard let self = self else { return Observable.never() }
                
                let balance = self.accountBalanceUseCase.balance(by: assetId,
                                                                 wallet: wallet)
                                                
                return balance
                    .flatMap { balance -> Observable<StakingTransfer.DTO.Data.Transfer> in
                        
                        let asset = balance.asset
                                                                    
                        let availableBalance: DomainLayer.DTO.Balance = balance.availableBalance()
                        
                        let fee: DomainLayer.DTO.Balance = asset.balance(Constanst.transferFee)
                        
                        let deposit: StakingTransfer.DTO.Data.Transfer = .init(asset: asset,
                                                                              balance: availableBalance,
                                                                              transactionFeeBalance: fee)
                     
                        
                        return Observable.just(deposit)
                    }
            }
    }
    
    func card(assetId: String) -> Observable<StakingTransfer.DTO.Data.Card> {
        return Observable.never()
    }
    
    func sendWithdraw(transfer: StakingTransfer.DTO.InputData.Transfer) -> Observable<Bool> {
        
        let developmentConfigs = self.developmentConfigsRepository.developmentConfigs()
        let authorizedWallet = self.authorizationUseCase.authorizedWallet()
        
//        Observable<DomainLayer.DTO.SmartTransaction>
//address_stacking_contract
        return Observable.zip(developmentConfigs, authorizedWallet)
            .flatMap { [weak self] configs, wallet -> Observable<Bool> in
            
                guard let self = self else { return Observable.never() }
                
                let args: [InvokeScriptTransactionSender.Arg] = .init()
                
                let call = InvokeScriptTransactionSender.Call.init(function: "",
                                                                   args: args)
                
                let payments: [InvokeScriptTransactionSender.Payment] = .init()
                
                var sender: InvokeScriptTransactionSender = .init(fee: Constanst.transferFee,
                                                                  feeAssetId: WavesSDKConstants.wavesAssetId,
                                                                  dApp: "",
                                                                  call: call,
                                                                  payment: payment)
                
                let specifications: TransactionSenderSpecifications = .invokeScript(sender)
                return self.transactionUseCase
                    .send(by: specifications,
                          wallet: wallet)
                    .map { _ in true }
            }
        
        return Observable.never()
    }
    
    func sendDeposit(transfer: StakingTransfer.DTO.InputData.Transfer) -> Observable<Bool> {
        
        return Observable.never()
    }
    
    func sendWithdraw() -> Observable<Bool> {
        
        return Observable.never()
    }
    
    private func stakingBalance() -> Observable<DomainLayer.DTO.Balance> {
        
        let balance: DomainLayer.DTO.Balance = DomainLayer.DTO.Balance.init(currency: .init(title: "USDN",
                                                                                            ticker: "USDN"),
                                                                            money: Money.init(10000000,
                                                                                              6))
        return Observable.just(balance)
    }
}


//TODO: Move
extension DomainLayer.DTO.Asset {
    
    func balance(_ balance: Int64) -> DomainLayer.DTO.Balance {
        return .init(currency: .init(title: self.name,
                                     
                                     ticker: self.ticker),
                     money: Money.init(balance,
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
        let value = Decimal(amount) * (percent.rawValue / 100.0)
        
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
