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
    
    func generateMoneroAddress(asset: DomainLayer.DTO.SmartAssetBalance, address: String, paymentID: String) -> Observable<ResponseType<String>> {
        
        return Observable.create({ [weak self] (subscribe) -> Disposable in
            
            let asset = asset.asset

            self?.getAssetTunnelInfo(asset: asset, address: address, moneroPaymentID: paymentID, complete: { (shortName, address, attachment, error) in
                
                if let address = address {
                    subscribe.onNext(ResponseType(output: address, error: nil))
                }
                else {
                    subscribe.onNext(ResponseType(output: nil, error: error))
                }
            })
            return Disposables.create()
        })
       
    }
    
    func gateWayInfo(asset: DomainLayer.DTO.SmartAssetBalance, address: String) -> Observable<ResponseType<Send.DTO.GatewayInfo>> {
        
        return Observable.create({ [weak self] subscribe -> Disposable in
        
            let asset = asset.asset
            
            self?.getAssetRate(asset: asset, complete: { (fee, min, max, errorMessage) in

                if let fee = fee, let min = min, let max = max {

                    self?.getAssetTunnelInfo(asset: asset, address: address, moneroPaymentID: "", complete: { (shortName, address, attachment, error) in
                        
                        if let shortName = shortName, let address = address, let attachment = attachment {
                            
                            let gatewayInfo = Send.DTO.GatewayInfo(assetName: asset.displayName,
                                                                   assetShortName: shortName,
                                                                   minAmount: min,
                                                                   maxAmount: max,
                                                                   fee: fee,
                                                                   address: address,
                                                                   attachment: attachment)
                            
                            subscribe.onNext(ResponseType(output: gatewayInfo, error: nil))
                        }
                        else {
                            subscribe.onNext(ResponseType(output: nil, error: errorMessage))
                        }
                    })
                }
                else {
                    subscribe.onNext(ResponseType(output: nil, error: errorMessage))
                }
            })
            
            return Disposables.create()
        })
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
    
    func getAssetTunnelInfo(asset: DomainLayer.DTO.Asset, address: String, moneroPaymentID: String, complete:@escaping(_ shortName: String?, _ address: String?, _ attachment: String?, _ error: NetworkError?) -> Void) {
        
        var params = ["currency_from" : asset.wavesId ?? "",
                      "currency_to" : asset.gatewayId ?? "",
                      "wallet_to" : address]
        
        if moneroPaymentID.count > 0 {
            params["monero_payment_id"] = moneroPaymentID
        }
        
        //TODO: need change to Observer network
        NetworkManager.getRequestWithUrl(GlobalConstants.Coinomat.createTunnel, parameters: params) { (info, error) in
            if let tunnel = info {
                
                let params = ["xt_id" : tunnel["tunnel_id"].stringValue,
                              "k1" : tunnel["k1"].stringValue,
                              "k2": tunnel["k2"].stringValue,
                              "history" : 0] as [String: Any]
                
                NetworkManager.getRequestWithUrl(GlobalConstants.Coinomat.getTunnel, parameters: params, complete: { (info, error) in
                    
                    if let info = info {
                        let json = info["tunnel"]
                        let shortName = asset.gatewayId ?? json["currency_from_txt"].stringValue
                        let address = json["wallet_from"].stringValue
                        let attachment = json["attachment"].stringValue
                        
                        complete(shortName, address, attachment, nil)
                    }
                    else {
                        complete(nil, nil, nil, error)
                    }
                })
            }
            else {
                complete(nil, nil, nil, error)
            }
        }
    }
    
    func getAssetRate(asset: DomainLayer.DTO.Asset, complete:@escaping(_ fee: Money?, _ min: Money?, _ max: Money?, _ error: NetworkError?) -> Void) {
        
        let params = ["f" : asset.wavesId ?? "",
                      "t" : asset.gatewayId ?? ""]
        
        //TODO: need change to Observer network
        NetworkManager.getRequestWithUrl(GlobalConstants.Coinomat.getRate, parameters: params) { (info, error) in
            
            var fee: Money?
            var min: Money?
            var max: Money?

            if let json = info {
                fee = Money(value: Decimal(json["fee_in"].doubleValue + json["fee_out"].doubleValue), asset.precision)
                min = Money(value: Decimal(json["in_min"].doubleValue), asset.precision)
                max = Money(value: Decimal(json["in_max"].doubleValue), asset.precision)
            }

            complete(fee, min, max, error)
        }
    }
    
}
