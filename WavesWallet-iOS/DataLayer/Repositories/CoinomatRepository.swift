//
//  CoinomatRepository.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/14/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

final class CoinomatRepository: CoinomatRepositoryProtocol {
    
    private let auth = FactoryInteractors.instance.authorization
    
    func tunnelInfo(currencyFrom: String, currencyTo: String, walletTo: String, moneroPaymentID: String?) -> Observable<DomainLayer.DTO.Coinomat.TunnelInfo> {
    
        return Observable.create({ (subscribe) -> Disposable in
            
            var params = ["currency_from" : currencyFrom,
                          "currency_to" : currencyTo,
                          "wallet_to" : walletTo]
            
            if let moneroPaymentID = moneroPaymentID, moneroPaymentID.count > 0 {
                params["monero_payment_id"] = moneroPaymentID
            }
            
            NetworkManager.getRequestWithUrl(GlobalConstants.Coinomat.createTunnel, parameters: params) { (info, error) in
               
                if let error = error {
                    subscribe.onError(error)
                }
                else if let tunnel = info {
                    
                    let params = ["xt_id" : tunnel["tunnel_id"].stringValue,
                                  "k1" : tunnel["k1"].stringValue,
                                  "k2": tunnel["k2"].stringValue,
                                  "history" : 0] as [String: Any]
                    
                    NetworkManager.getRequestWithUrl(GlobalConstants.Coinomat.getTunnel, parameters: params, complete: { (info, error) in
                        
                        if let error = error {
                            subscribe.onError(error)
                        }
                        else if let info = info {
                            let json = info["tunnel"]
                            
                            let model = DomainLayer.DTO.Coinomat.TunnelInfo(address: json["wallet_from"].stringValue,
                                                                            attachment: json["attachment"].stringValue)
                            subscribe.onNext(model)
                            subscribe.onCompleted()
                            
                        }
                    })
                }
            }
            
            return Disposables.create()
        })
    }
    
    func getRate(asset: DomainLayer.DTO.Asset) -> Observable<DomainLayer.DTO.Coinomat.Rate> {
        
        return Observable.create({ (subscribe) -> Disposable in
            
            let params = ["f" : asset.wavesId ?? "",
                          "t" : asset.gatewayId ?? ""]
            
            NetworkManager.getRequestWithUrl(GlobalConstants.Coinomat.getRate, parameters: params) { (info, error) in
                
                if let error = error {
                    subscribe.onError(error)
                }
                else if let json = info {
                    let fee = Money(value: Decimal(json["fee_in"].doubleValue + json["fee_out"].doubleValue), asset.precision)
                    let min = Money(value: Decimal(json["in_min"].doubleValue), asset.precision)
                    let max = Money(value: Decimal(json["in_max"].doubleValue), asset.precision)

                    subscribe.onNext(DomainLayer.DTO.Coinomat.Rate(fee: fee, min: min, max: max))
                    subscribe.onCompleted()
                }
            }
            
            return Disposables.create()
        })
    }
    
    func cardLimits(address: String, fiat: String) -> Observable<DomainLayer.DTO.Coinomat.CardLimit> {
        
        return Observable.create({ (subscribe) -> Disposable in
            
            let params = ["crypto" : GlobalConstants.wavesAssetId,
                          "address" : address,
                          "fiat" : fiat]
            
            NetworkManager.getRequestWithUrl(GlobalConstants.Coinomat.getLimits, parameters: params, complete: { (info, error) in
                
                if let error = error {
                    subscribe.onError(error)
                }
                else if let json = info {
                    
                    let min = Money(value: Decimal(json["min"].intValue), GlobalConstants.FiatDecimals)
                    let max = Money(value: Decimal(json["max"].intValue), GlobalConstants.FiatDecimals)
                    
                    let model = DomainLayer.DTO.Coinomat.CardLimit(min: min, max: max)
                    subscribe.onNext(model)
                    subscribe.onCompleted()
                }
            })
            
            return Disposables.create()
        })
    }
}
