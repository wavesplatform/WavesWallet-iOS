//
//  CoinomatRepository.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/14/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

private enum Response {
    
    struct CreateTunnel: Decodable {
        let k1: String
        let k2: String
        let tunnel_id: Int
    }
    
    struct TunnelInfo: Decodable {
        
        struct Tunnel: Decodable {
            let currency_from: String
            let attachment: String
        }
        
        let tunnel: Tunnel
    }
    
    struct Rate: Decodable {
        let fee_in: Double
        let fee_out: Double
        let in_max: Double
        let in_min: Double
    }
    
    struct Limit: Decodable {
        let min: Double
        let max: Double
    }
}

private enum Constants {
  
    enum Tunnel {
        static let currencyFrom = "currency_from"
        static let currencyTo = "currency_to"
        static let walletTo = "wallet_to"
        static let moneroPaymentID = "monero_payment_id"
        static let xtID = "xt_id"
        static let k1 = "k1"
        static let k2 = "k2"
        static let history = "history"
    }
    
    enum Rate {
        static let from = "f"
        static let to = "t"
    }
    
    enum Limit {
        static let crypto = "crypto"
        static let address = "address"
        static let fiat = "fiat"
    }
}

final class CoinomatRepository: CoinomatRepositoryProtocol {
        
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
                else if let data = info.data {
                    
                    do {
                        let model = try JSONDecoder().decode(Response.CreateTunnel.self, from: data)
                        
                        let params = [Constants.Tunnel.xtID : model.tunnel_id,
                                      Constants.Tunnel.k1 : model.k1,
                                      Constants.Tunnel.k2: model.k2,
                                      Constants.Tunnel.history : 0] as [String: Any]

                        NetworkManager.getRequestWithUrl(GlobalConstants.Coinomat.getTunnel, parameters: params, complete: { (info, error) in
                            
                            if let error = error {
                                subscribe.onError(error)
                            }
                            else if let data = info.data {
                                do {
                                    let model = try JSONDecoder().decode(Response.TunnelInfo.self, from: data)
                                    
                                    let tunnel = DomainLayer.DTO.Coinomat.TunnelInfo(address: model.tunnel.currency_from,
                                                                                     attachment: model.tunnel.attachment)

                                    subscribe.onNext(tunnel)
                                    subscribe.onCompleted()
                                }
                                catch let error {
                                    subscribe.onError(error)
                                }
                            }
                        })
                    }
                    catch let error {
                        subscribe.onError(error)
                    }
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
                else if let data = info.data {
                    
                    do {
                        let model = try JSONDecoder().decode(Response.Rate.self, from: data)
                        
                        let fee = Money(value: Decimal(model.fee_in + model.fee_out), asset.precision)
                        let min = Money(value: Decimal(model.in_min), asset.precision)
                        let max = Money(value: Decimal(model.in_max), asset.precision)
                        
                        subscribe.onNext(DomainLayer.DTO.Coinomat.Rate(fee: fee, min: min, max: max))
                        subscribe.onCompleted()

                    }
                    catch let error {
                        subscribe.onError(error)
                    }
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
                else if let data = info.data {
                    
                    do {
                        let model = try JSONDecoder().decode(Response.Limit.self, from: data)
                        
                        let min = Money(value: Decimal(model.min), GlobalConstants.FiatDecimals)
                        let max = Money(value: Decimal(model.max), GlobalConstants.FiatDecimals)

                        subscribe.onNext(DomainLayer.DTO.Coinomat.CardLimit(min: min, max: max))
                        subscribe.onCompleted()
                    }
                    catch let error {
                        subscribe.onError(error)
                    }
                }
            })
            
            return Disposables.create()
        })
    }
}
