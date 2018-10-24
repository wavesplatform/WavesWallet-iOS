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


private enum Constasts {
    static let aliasApi = "/v0/aliases/"

    static let coinomatApiPath = "api/v1/"
    
    static let coinomatCreateTunnel = "create_tunnel.php"
    static let coinomatGetTunnel = "get_tunnel.php"
}

final class SendInteractor: SendInteractorProtocol {
    
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
    
    func gateWayInfo(asset: DomainLayer.DTO.AssetBalance, address: String) -> Observable<Response<Send.DTO.GatewayInfo>> {
       
        return Observable.create({ (subscribe) -> Disposable in
        
            guard let asset = asset.asset else { return Disposables.create() }
            
            let params = ["currency_from" : asset.gatewayId ?? "",
                          "currency_to" : asset.wavesId ?? "",
                          "wallet_to" : address]

            let url = GlobalConstants.coinomatUrl + Constasts.coinomatApiPath + Constasts.coinomatCreateTunnel

            NetworkManager.getRequestWithPath(path: "", parameters: params, customUrl: url, complete: { (info, errorMessage) in
                guard let info = info else {
                    subscribe.onNext(Response(output: nil, error: errorMessage))
                    return
                }
                
                let tunnel = JSON(info)
                let params = ["xt_id" : tunnel["tunnel_id"].stringValue,
                              "k1" : tunnel["k1"].stringValue,
                              "k2": tunnel["k2"].stringValue,
                              "history" : 0] as [String: Any]
                
                let url = GlobalConstants.coinomatUrl + Constasts.coinomatApiPath + Constasts.coinomatGetTunnel
                
                NetworkManager.getRequestWithPath(path: "", parameters: params, customUrl: url, complete: { (info, errorMessage) in
                    
                    guard let info = info else {
                        subscribe.onNext(Response(output: nil, error: errorMessage))
                        return
                    }
                    
                    let json = JSON(info)["tunnel"]
                    let shortName = asset.gatewayId ?? json["to_txt"].stringValue
                    let min = Money(value: Decimal(json["in_min"].doubleValue), asset.precision)
                    let max = Money(value: Decimal(json["in_max"].doubleValue), asset.precision)
                 
                    //TODO: chacnge fee field
                    let fee = Money(value: Decimal(json["in_min"].doubleValue), asset.precision)

                    let gatewayInfo = Send.DTO.GatewayInfo(assetName: asset.displayName,
                                                           assetShortName: shortName,
                                                           minAmount: min,
                                                           maxAmount: max,
                                                           fee: fee,
                                                           address: json["wallet_from"].stringValue)
                    
                    subscribe.onNext(Response(output: gatewayInfo, error: nil))
                })
                
                
            })
            
            return Disposables.create()
        })
    }
    
    func validateAlis(alias: String) -> Observable<Bool> {
        
        return Observable.create({ (subscribe) -> Disposable in
        
            let url = Environments.current.servers.dataUrl.relativeString + Constasts.aliasApi + alias

            let req = NetworkManager.getRequestWithPath(path: "", parameters: nil, customUrl: url, complete: { (info, errorMessage) in
                subscribe.onNext(errorMessage == nil)
            })
            
            return Disposables.create {
                req.cancel()
            }
        })
    }
    
    
    func send(fee: Money, recipient: String, assetId: String, amount: Money, attachment: String, isAlias: Bool) -> Observable<Bool> {
        return Observable.create({ (subscribe) -> Disposable in
            
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
                
                
            }).dispose()
            return Disposables.create()
        })
    }
}
