//
//  SendInteractor.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/17/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON
import Alamofire

private enum Constasts {
    static let aliasApi = "/v0/aliases/"
    static let transactionApi = "/transactions/broadcast"
}

final class SendInteractor: SendInteractorProtocol {
    
    private let disposeBag = DisposeBag()
    private let accountBalanceInteractor: AccountBalanceInteractorProtocol = FactoryInteractors.instance.accountBalance
    private let assetInteractor = FactoryInteractors.instance.assetsInteractor
    private let auth = FactoryInteractors.instance.authorization
    private let coinomatRepository = FactoryRepositories.instance.coinomatRepository
    
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
    
    func getWavesBalance() -> Observable<DomainLayer.DTO.SmartAssetBalance> {
        
        //TODO: need to checkout if we need you use force update balance
        //because we can make transaction only if balance > 0, waves fee = 0.001
        //isNeedUpdate = false, because Send UI no need waiting animation state
        
        let accountBalance = FactoryInteractors.instance.accountBalance
        return accountBalance.balances()
            .flatMap({ balances -> Observable<DomainLayer.DTO.SmartAssetBalance> in
                
                guard let wavesAsset = balances.first(where: {$0.asset.wavesId == Environments.Constants.wavesAssetId}) else {
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
        
        return Observable.create({ (subscribe) -> Disposable in
        
            //TODO: need use EnviromentsRepositoryProtocol            
            let url = Environments.current.servers.dataUrl.relativeString + Constasts.aliasApi + alias

            let req = NetworkManager.getRequestWithUrl(url, parameters: nil, complete: { (info, errorMessage) in
                subscribe.onNext(errorMessage == nil)
            })
            
            return Disposables.create {
                req.cancel()
            }
        })
    }
    
    
    func send(fee: Money, recipient: String, assetId: String, amount: Money, attachment: String, isAlias: Bool) -> Observable<Send.TransactionStatus> {
       
        return Observable.create({ [weak self] subscribe -> Disposable in
            
            guard let strongSelf = self else { return Disposables.create() }
            
            let auth: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization
            auth.authorizedWallet().subscribe(onNext: { signedWallet in
                
                let transaction = Send.DTO.Transaction(senderPublicKey: signedWallet.publicKey,
                                                       senderPrivateKey: signedWallet.privateKey,
                                                       fee: fee,
                                                       recipient: recipient,
                                                       assetId: assetId,
                                                       amount: amount,
                                                       attachment: attachment,
                                                       isAlias: isAlias)
                
                let params = ["type" : transaction.type,
                              "senderPublicKey" : Base58.encode(transaction.senderPublicKey.publicKey),
                              "fee" : transaction.fee.amount,
                              "timestamp" : transaction.timestamp,
                              "proofs" : transaction.proofs,
                              "version" : transaction.version,
                              "recipient" : transaction.recipient,
                              "assetId" : transaction.assetId,
                              "feeAssetId" : transaction.feeAssetId,
                              "feeAsset" : transaction.feeAsset,
                              "amount" : transaction.amount.amount,
                              "attachment" : Base58.encode(Array(transaction.attachment.utf8))] as [String : Any]
                
                //TODO: need to use EnvironmentsRepositoryProtocol
                
                let url = Environments.current.servers.nodeUrl.appendingPathComponent(Constasts.transactionApi).relativeString
                
                NetworkManager.postRequestWithUrl(url, parameters: params, complete: { (info, error) in
                    
                    if let error = error {
                        subscribe.onNext(.error(error))
                    }
                    else {
                        subscribe.onNext(.success)
                    }
                })
            }).disposed(by: strongSelf.disposeBag)
            
            return Disposables.create()
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
