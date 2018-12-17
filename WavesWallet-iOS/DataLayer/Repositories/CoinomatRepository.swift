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

private enum Constants {
    
    enum Tunnel {
        static let tunnel = "tunnel"
        static let currencyFrom = "currency_from"
        static let currencyTo = "currency_to"
        static let walletTo = "wallet_to"
        static let moneroPaymentID = "monero_payment_id"
        static let tunnelID = "tunnel_id"
        static let xtID = "xt_id"
        static let k1 = "k1"
        static let k2 = "k2"
        static let history = "history"
        static let attachment = "attachment"
    }
    
    enum Rate {
        static let from = "f"
        static let to = "t"
        static let feeIn = "fee_in"
        static let feeOut = "fee_out"
        static let inMax = "in_max"
        static let inMin = "in_min"
    }
    
    enum Limit {
        static let crypto = "crypto"
        static let address = "address"
        static let fiat = "fiat"
        static let min = "min"
        static let max = "max"
    }
}

final class CoinomatRepository: CoinomatRepositoryProtocol {
    
    private let auth = FactoryInteractors.instance.authorization
    
    func tunnelInfo(currencyFrom: String, currencyTo: String, walletTo: String, moneroPaymentID: String?) -> Observable<DomainLayer.DTO.Coinomat.TunnelInfo> {
    
        return Observable.create({ (subscribe) -> Disposable in
            
            var params = [Constants.Tunnel.currencyFrom : currencyFrom,
                         Constants.Tunnel.currencyTo : currencyTo,
                          Constants.Tunnel.walletTo : walletTo]
            
            if let moneroPaymentID = moneroPaymentID, moneroPaymentID.count > 0 {
                params[Constants.Tunnel.moneroPaymentID] = moneroPaymentID
            }
            
            NetworkManager.getRequestWithUrl(GlobalConstants.Coinomat.createTunnel, parameters: params) { (info, error) in
               
                if let error = error {
                    subscribe.onError(error)
                }
                else if let tunnel = info {
                    
                    let params = [Constants.Tunnel.xtID : tunnel[Constants.Tunnel.tunnelID].stringValue,
                                  Constants.Tunnel.k1 : tunnel[Constants.Tunnel.k1].stringValue,
                                  Constants.Tunnel.k2: tunnel[Constants.Tunnel.k2].stringValue,
                                  Constants.Tunnel.history   : 0] as [String: Any]
                    
                    NetworkManager.getRequestWithUrl(GlobalConstants.Coinomat.getTunnel, parameters: params, complete: { (info, error) in
                        
                        if let error = error {
                            subscribe.onError(error)
                        }
                        else if let info = info {
                            let json = info[Constants.Tunnel.tunnel]
                            
                            let model = DomainLayer.DTO.Coinomat.TunnelInfo(address: json[Constants.Tunnel.currencyFrom].stringValue,
                                                                            attachment: json[Constants.Tunnel.attachment].stringValue)
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
            
            let params = [Constants.Rate.from : asset.wavesId ?? "",
                          Constants.Rate.to : asset.gatewayId ?? ""]
            
            NetworkManager.getRequestWithUrl(GlobalConstants.Coinomat.getRate, parameters: params) { (info, error) in
                
                if let error = error {
                    subscribe.onError(error)
                }
                else if let json = info {
                    
                    let feeValue = Decimal(json[Constants.Rate.feeIn].doubleValue + json[Constants.Rate.feeOut].doubleValue)
                    let fee = Money(value: feeValue, asset.precision)
                    let min = Money(value: Decimal(json[Constants.Rate.inMin].doubleValue), asset.precision)
                    let max = Money(value: Decimal(json[Constants.Rate.inMax].doubleValue), asset.precision)

                    subscribe.onNext(DomainLayer.DTO.Coinomat.Rate(fee: fee, min: min, max: max))
                    subscribe.onCompleted()
                }
            }
            
            return Disposables.create()
        })
    }
    
    func cardLimits(address: String, fiat: String) -> Observable<DomainLayer.DTO.Coinomat.CardLimit> {
        
        return Observable.create({ (subscribe) -> Disposable in
            
            let params = [Constants.Limit.crypto : GlobalConstants.wavesAssetId,
                          Constants.Limit.address : address,
                          Constants.Limit.fiat : fiat]
            
            NetworkManager.getRequestWithUrl(GlobalConstants.Coinomat.getLimits, parameters: params, complete: { (info, error) in
                
                if let error = error {
                    subscribe.onError(error)
                }
                else if let json = info {
                    
                    let min = Money(value: Decimal(json[Constants.Limit.min].intValue), GlobalConstants.FiatDecimals)
                    let max = Money(value: Decimal(json[Constants.Limit.max].intValue), GlobalConstants.FiatDecimals)
                    
                    let model = DomainLayer.DTO.Coinomat.CardLimit(min: min, max: max)
                    subscribe.onNext(model)
                    subscribe.onCompleted()
                }
            })
            
            return Disposables.create()
        })
    }
}
