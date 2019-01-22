//
//  SendInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/17/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

final class SendInteractor: SendInteractorProtocol {
    
    private let accountBalanceInteractor: AccountBalanceInteractorProtocol = FactoryInteractors.instance.accountBalance
    private let assetInteractor = FactoryInteractors.instance.assetsInteractor
    private let auth = FactoryInteractors.instance.authorization
    private let coinomatRepository = FactoryRepositories.instance.coinomatRepository
    private let aliasRepository = FactoryRepositories.instance.aliasesRepository
    private let transactionInteractor: TransactionsInteractorProtocol = FactoryInteractors.instance.transactions
    private let accountBalance = FactoryInteractors.instance.accountBalance

    func assetBalance(by assetID: String) -> Observable<DomainLayer.DTO.SmartAssetBalance?> {
        return accountBalanceInteractor.balances().flatMap({ [weak self] (balances) -> Observable<DomainLayer.DTO.SmartAssetBalance?>  in
            
            if let asset = balances.first(where: {$0.assetId == assetID}) {
                return Observable.just(asset)
            }
            
            guard let owner = self else { return Observable.empty() }
            return owner.auth.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<DomainLayer.DTO.SmartAssetBalance?> in
                guard let owner = self else { return Observable.empty() }
                return owner.assetInteractor.assets(by: [assetID], accountAddress: wallet.address, isNeedUpdated: false)
                    .flatMap({ (assets) -> Observable<DomainLayer.DTO.SmartAssetBalance?> in
                        
                        var assetBalance: DomainLayer.DTO.SmartAssetBalance?
                        if let asset = assets.first(where: {$0.id == assetID}) {
                            assetBalance = .init(assetId: asset.id,
                                                 totalBalance: 0,
                                                 leasedBalance: 0,
                                                 inOrderBalance: 0,
                                                 settings: .init(assetId: asset.id, sortLevel: 0, isHidden: false, isFavorite: false),
                                                 asset: asset,
                                                 modified: asset.modified)
                        }
                        return Observable.just(assetBalance)
                    })

            })
        }).catchError({ (error) -> Observable<DomainLayer.DTO.SmartAssetBalance?> in
            return Observable.just(nil)
        })
    }
    
    func calculateFee(assetID: String) -> Observable<Money> {
        return auth.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<Money> in
            guard let owner = self else { return Observable.empty() }
            return owner.transactionInteractor.calculateFee(by: .sendTransaction(assetID: assetID), accountAddress: wallet.address)
        })
        .catchError({ (error) -> Observable<Money> in
            return Observable.just(GlobalConstants.WavesTransactionFee)
        })
    }
    
    func getWavesBalance() -> Observable<DomainLayer.DTO.SmartAssetBalance> {

        //TODO: need optimization
        
        return accountBalance.balances()
            .flatMap({ balances -> Observable<DomainLayer.DTO.SmartAssetBalance> in
                
                guard let wavesAsset = balances.first(where: {$0.asset.wavesId == GlobalConstants.wavesAssetId}) else {
                    return Observable.empty()
                }
                return Observable.just(wavesAsset)
            })
    }
    
    func generateMoneroAddress(asset: DomainLayer.DTO.SmartAssetBalance, address: String, paymentID: String) -> Observable<ResponseType<Send.DTO.GatewayInfo>> {
        
        return gateWayInfo(asset: asset.asset, address: address, moneroPaymentID: paymentID)
       
    }
    
    func gateWayInfo(asset: DomainLayer.DTO.SmartAssetBalance, address: String) -> Observable<ResponseType<Send.DTO.GatewayInfo>> {
        return gateWayInfo(asset: asset.asset, address: address, moneroPaymentID: nil)
    }
    
    func validateAlis(alias: String) -> Observable<Bool> {

        return auth.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<Bool> in
            guard let owner = self else { return Observable.empty() }
            
            return owner.aliasRepository.alias(by: alias, accountAddress: wallet.address)
                .flatMap({ (alias) -> Observable<Bool>  in
                    return Observable.just(true)
            })
        })
        .catchError({ (error) -> Observable<Bool> in
            return Observable.just(false)
        })
    }
    
    
    func send(fee: Money, recipient: String, assetId: String, amount: Money, attachment: String) -> Observable<Send.TransactionStatus> {
       
        return auth.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<Send.TransactionStatus> in
            guard let owner = self else { return Observable.empty() }

            let sender = SendTransactionSender(recipient: recipient,
                                               assetId: assetId,
                                               amount: amount.amount,
                                               fee: fee.amount,
                                               attachment: attachment)
            return owner.transactionInteractor.send(by: TransactionSenderSpecifications.send(sender), wallet: wallet)
                .flatMap({ (transaction) -> Observable<Send.TransactionStatus>  in
                    return Observable.just(.success)
                })
        })
        .catchError({ (error) -> Observable<Send.TransactionStatus> in
            if let error = error as? NetworkError {
                return Observable.just(.error(error))
            }
            return Observable.just(.error(NetworkError.error(by: error)))
        })
    }
}

private extension SendInteractor {
    
    func gateWayInfo(asset: DomainLayer.DTO.Asset, address: String, moneroPaymentID: String?) -> Observable<ResponseType<Send.DTO.GatewayInfo>> {
        
        guard let currencyFrom = asset.wavesId,
            let currencyTo = asset.gatewayId else { return Observable.empty() }
        
        let tunnel = coinomatRepository.tunnelInfo(currencyFrom: currencyFrom,
                                                   currencyTo: currencyTo,
                                                   walletTo: address,
                                                   moneroPaymentID: moneroPaymentID)
        
        let rate = coinomatRepository.getRate(asset: asset)
        
        return Observable.zip(tunnel, rate).flatMap({ (tunnel, rate) -> Observable<ResponseType<Send.DTO.GatewayInfo>> in
            
            let gatewayInfo = Send.DTO.GatewayInfo(assetName: asset.displayName,
                                                   assetShortName: currencyTo,
                                                   minAmount: rate.min,
                                                   maxAmount: rate.max,
                                                   fee: rate.fee,
                                                   address: tunnel.address,
                                                   attachment: tunnel.attachment)
            return Observable.just(ResponseType(output: gatewayInfo, error: nil))
        })
        .catchError({ (error) -> Observable<ResponseType<Send.DTO.GatewayInfo>> in
            if let networkError = error as? NetworkError {
                return Observable.just(ResponseType(output: nil, error: networkError))
            }

            return Observable.just(ResponseType(output: nil, error: NetworkError.error(by: error)))
        })
    }
}
