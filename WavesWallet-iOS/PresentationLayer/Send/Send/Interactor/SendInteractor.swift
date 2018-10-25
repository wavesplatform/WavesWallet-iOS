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
    
    func getWavesBalance() -> Observable<DomainLayer.DTO.AssetBalance> {
        
        //TODO: need to checkout if we need you use force update balance
        //because we can make transaction only if balance > 0, waves fee = 0.001
        //isNeedUpdate = false, because Send UI no need waiting animation state
        
        let accountBalance = FactoryInteractors.instance.accountBalance
        return accountBalance.balances(isNeedUpdate: false)
            .flatMap({ balances -> Observable<DomainLayer.DTO.AssetBalance> in
                
                guard let wavesAsset = balances.first(where: {$0.asset?.wavesId == Environments.Constants.wavesAssetId}) else {
                    return Observable.empty()
                }
                return Observable.just(wavesAsset)
            })
    }
    
    func gateWayInfo(asset: DomainLayer.DTO.AssetBalance, address: String) -> Observable<ResponseType<Send.DTO.GatewayInfo>> {
       
        return Observable.create({ [weak self] subscribe -> Disposable in
        
            guard let asset = asset.asset else { return Disposables.create() }
            
            self?.getAssetRate(asset: asset, complete: { (fee, min, max, errorMessage) in

                if let fee = fee, let min = min, let max = max {

                    self?.getAssetTunnelInfo(asset: asset, address: address, complete: { (shortName, address, errorMessage) in
                        
                        if let shortName = shortName, let address = address {
                            
                            let gatewayInfo = Send.DTO.GatewayInfo(assetName: asset.displayName,
                                                                   assetShortName: shortName,
                                                                   minAmount: min,
                                                                   maxAmount: max,
                                                                   fee: fee,
                                                                   address: address)
                            
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

            let req = NetworkManager.getRequestWithPath(path: "", parameters: nil, customUrl: url, complete: { (info, errorMessage) in
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
                
                NetworkManager.postRequestWithPath(path: "", parameters: params, customUrl: url, complete: { (info, errorMessage) in
                    
                    if let error = errorMessage {
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
    
    func getAssetTunnelInfo(asset: DomainLayer.DTO.Asset, address: String, complete:@escaping(_ shortName: String?, _ address: String?, _ errorMessage: String?) -> Void) {
        
        let params = ["currency_from" : asset.wavesId ?? "",
                      "currency_to" : asset.gatewayId ?? "",
                      "wallet_to" : address]
        
        NetworkManager.getRequestWithPath(path: "", parameters: params, customUrl: GlobalConstants.Coinomat.createTunnel) { (info, errorMessage) in
            if let info = info {
                
                let tunnel = JSON(info)
                let params = ["xt_id" : tunnel["tunnel_id"].stringValue,
                              "k1" : tunnel["k1"].stringValue,
                              "k2": tunnel["k2"].stringValue,
                              "history" : 0] as [String: Any]
                
                NetworkManager.getRequestWithPath(path: "", parameters: params, customUrl: GlobalConstants.Coinomat.getTunnel, complete: { (info, errorMessage) in
                    if let info = info {
                        
                        let json = JSON(info)["tunnel"]
                        let shortName = asset.gatewayId ?? json["to_txt"].stringValue
                        let address = json["wallet_from"].stringValue
                        
                        complete(shortName, address, nil)
                    }
                    else {
                        complete(nil, nil, errorMessage)
                    }
                })
            }
            else {
                complete(nil, nil, errorMessage)
            }
        }
    }
    
    func getAssetRate(asset: DomainLayer.DTO.Asset, complete:@escaping(_ fee: Money?, _ min: Money?, _ max: Money?, _ errorMessage: String?) -> Void) {
        
        let params = ["f" : asset.wavesId ?? "",
                      "t" : asset.gatewayId ?? ""]
        

        NetworkManager.getRequestWithPath(path: "", parameters: params, customUrl: GlobalConstants.Coinomat.getRate) { (info, errorMessage) in
            
            var fee: Money?
            var min: Money?
            var max: Money?

            if let info = info {
                let json = JSON(info)
                fee = Money(value: Decimal(json["fee_in"].doubleValue + json["fee_out"].doubleValue), asset.precision)
                min = Money(value: Decimal(json["in_min"].doubleValue), asset.precision)
                max = Money(value: Decimal(json["in_max"].doubleValue), asset.precision)
            }

            complete(fee, min, max, errorMessage)
        }
    }
    
}
