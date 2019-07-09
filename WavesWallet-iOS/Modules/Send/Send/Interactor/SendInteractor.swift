//
//  SendInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/17/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import WavesSDKExtensions
import WavesSDK
import Extensions
import DomainLayer

final class SendInteractor: SendInteractorProtocol {
    
    private let accountBalanceInteractor: AccountBalanceUseCaseProtocol = UseCasesFactory.instance.accountBalance
    private let assetInteractor = UseCasesFactory.instance.assets
    private let auth = UseCasesFactory.instance.authorization
    private let coinomatRepository = UseCasesFactory.instance.repositories.coinomatRepository
    private let aliasRepository = UseCasesFactory.instance.repositories.aliasesRepositoryRemote
    private let transactionInteractor: TransactionsUseCaseProtocol = UseCasesFactory.instance.transactions
    private let accountBalance = UseCasesFactory.instance.accountBalance
    private let gatewayRepository = UseCasesFactory.instance.repositories.gatewayRepository
    
    func assetBalance(by assetID: String) -> Observable<DomainLayer.DTO.SmartAssetBalance?> {
        return accountBalanceInteractor.balances().flatMap({ [weak self] (balances) -> Observable<DomainLayer.DTO.SmartAssetBalance?>  in
            
            if let asset = balances.first(where: {$0.assetId == assetID}) {
                return Observable.just(asset)
            }
            
            guard let self = self else { return Observable.empty() }
            return self.auth.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<DomainLayer.DTO.SmartAssetBalance?> in
                guard let self = self else { return Observable.empty() }
                return self.assetInteractor.assets(by: [assetID], accountAddress: wallet.address)
                    .flatMap({ (assets) -> Observable<DomainLayer.DTO.SmartAssetBalance?> in
                        
                        var assetBalance: DomainLayer.DTO.SmartAssetBalance?
                        if let asset = assets.first(where: {$0.id == assetID}) {
                            assetBalance = .init(assetId: asset.id,
                                                 totalBalance: 0,
                                                 leasedBalance: 0,
                                                 inOrderBalance: 0,
                                                 settings: .init(assetId: asset.id, sortLevel: 0, isHidden: false, isFavorite: false),
                                                 asset: asset,
                                                 modified: asset.modified,
                                                 sponsorBalance: 0)
                        }
                        return Observable.just(assetBalance)
                    })

            })
        }).catchError({ (error) -> Observable<DomainLayer.DTO.SmartAssetBalance?> in
            return Observable.just(nil)
        })
    }
    
    func calculateFee(assetID: String) -> Observable<Money> {
        return auth
            .authorizedWallet()
            .flatMap({ [weak self] (wallet) -> Observable<Money> in
                guard let self = self else { return Observable.empty() }
                return self.transactionInteractor.calculateFee(by: .sendTransaction(assetID: assetID), accountAddress: wallet.address)
            })
    }
    
    func getWavesBalance() -> Observable<DomainLayer.DTO.SmartAssetBalance> {

        //TODO: need optimization
        
        return accountBalance.balances()
            .flatMap({ balances -> Observable<DomainLayer.DTO.SmartAssetBalance> in
                
                guard let wavesAsset = balances.first(where: {$0.asset.wavesId == WavesSDKConstants.wavesAssetId}) else {
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

        return auth
            .authorizedWallet()
            .flatMap({ [weak self] (wallet) -> Observable<Bool> in
                guard let self = self else { return Observable.never() }
            
                return self.aliasRepository.alias(by: alias, accountAddress: wallet.address)
                    .flatMap({ (address) -> Observable<Bool>  in
                        return Observable.just(true)
                })
            })
            .catchError({ (error) -> Observable<Bool> in
                return Observable.just(false)
            })
    }
    
    func send(fee: Money, recipient: String, asset: DomainLayer.DTO.Asset, amount: Money, attachment: String, feeAssetID: String, isGatewayTransaction: Bool) -> Observable<Send.TransactionStatus> {
        
        return auth.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<Send.TransactionStatus> in
            guard let self = self else { return Observable.empty() }

            let assetId = asset.isWaves ? "" : asset.id

            let sender = SendTransactionSender(recipient: recipient,
                                               assetId: assetId,
                                               amount: amount.amount,
                                               fee: fee.amount,
                                               attachment: attachment,
                                               feeAssetID: feeAssetID)
            
            if isGatewayTransaction {
                guard let gatewayType = asset.gatewayType else { return Observable.empty() }
           
                switch gatewayType {
                case .coinomat:
                    return self.transactionInteractor.send(by: TransactionSenderSpecifications.send(sender), wallet: wallet)
                        .flatMap({ (transaction) -> Observable<Send.TransactionStatus>  in
                            return Observable.just(.success)
                        })
                case .gateway:
                    return self.gatewayRepository.send(by: TransactionSenderSpecifications.send(sender), wallet: wallet)
                        .flatMap({ (transaction) -> Observable<Send.TransactionStatus> in
                            return Observable.just(.success)
                        })
                }
            }
            else {
                return self.transactionInteractor.send(by: TransactionSenderSpecifications.send(sender), wallet: wallet)
                    .flatMap({ (transaction) -> Observable<Send.TransactionStatus>  in
                        return Observable.just(.success)
                    })
            }
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
        
        guard let gateWayType = asset.gatewayType else { return Observable.empty() }
        
        switch gateWayType {
        case .gateway:
            return gatewayRepository
                .startWithdrawProcess(address: address, asset: asset)
                .map({ (startProcessInfo) -> ResponseType<Send.DTO.GatewayInfo> in
                    
                    let gatewayInfo = Send.DTO.GatewayInfo(assetName: asset.displayName,
                                                           assetShortName: asset.ticker ?? "",
                                                           minAmount: startProcessInfo.minAmount,
                                                           maxAmount: startProcessInfo.maxAmount,
                                                           fee: startProcessInfo.fee,
                                                           address: startProcessInfo.recipientAddress,
                                                           attachment: startProcessInfo.processId)
                    return ResponseType(output: gatewayInfo, error: nil)
                })
                .catchError({ (error) -> Observable<ResponseType<Send.DTO.GatewayInfo>> in
                    if let networkError = error as? NetworkError {
                        return Observable.just(ResponseType(output: nil, error: networkError))
                    }
                    
                    return Observable.just(ResponseType(output: nil, error: NetworkError.error(by: error)))
                })
        
        case .coinomat:
            guard let currencyFrom = asset.wavesId,
                let currencyTo = asset.gatewayId else { return Observable.empty() }
            
            let tunnel = coinomatRepository.tunnelInfo(asset: asset,
                                                       currencyFrom: currencyFrom,
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
}
