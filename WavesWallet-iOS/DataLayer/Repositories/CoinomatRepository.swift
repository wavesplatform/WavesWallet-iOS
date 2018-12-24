//
//  CoinomatRepository.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/14/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift
import Moya

private enum Response {
    
    struct CreateTunnel: Decodable {
        let k1: String
        let k2: String
        let tunnel_id: Int
    }
    
    struct GetTunnel: Decodable {
        
        struct Tunnel: Decodable {
            let wallet_from: String
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
    
    struct CardLimit: Decodable {
        let min: Double
        let max: Double
    }
}

final class CoinomatRepository: CoinomatRepositoryProtocol {
    
    private let coinomatProvider: MoyaProvider<Coinomat.Service> = .coinomatMoyaProvider()

    func tunnelInfo(currencyFrom: String, currencyTo: String, walletTo: String, moneroPaymentID: String?) -> Observable<DomainLayer.DTO.Coinomat.TunnelInfo> {
        
        let tunnel = Coinomat.Service.CreateTunnel(currency_from: currencyFrom,
                                                   currency_to: currencyTo,
                                                   wallet_to: walletTo,
                                                   monero_payment_id: moneroPaymentID)

        return coinomatProvider.rx
        .request(.createTunnel(tunnel), callbackQueue:  DispatchQueue.global(qos: .background))
        .filterSuccessfulStatusAndRedirectCodes()
        .map(Response.CreateTunnel.self)
        .asObservable()
        .flatMap({ [weak self] (model) -> Observable<DomainLayer.DTO.Coinomat.TunnelInfo> in
            guard let owner = self else { return Observable.empty() }

            let tunnel = Coinomat.Service.GetTunnel(xt_id: model.tunnel_id,
                                                    k1: model.k1,
                                                    k2: model.k2)
            return owner.coinomatProvider.rx
            .request(.getTunnel(tunnel), callbackQueue:  DispatchQueue.global(qos: .background))
            .filterSuccessfulStatusAndRedirectCodes()
            .map(Response.GetTunnel.self)
            .asObservable()
            .map({ (model) -> DomainLayer.DTO.Coinomat.TunnelInfo in
                return DomainLayer.DTO.Coinomat.TunnelInfo(address: model.tunnel.wallet_from,
                                                           attachment: model.tunnel.attachment)
            })
        })
    }
    
    func getRate(asset: DomainLayer.DTO.Asset) -> Observable<DomainLayer.DTO.Coinomat.Rate> {
                
        let rate = Coinomat.Service.Rate(from: asset.wavesId ?? "",
                                         to: asset.gatewayId ?? "")
        
        return coinomatProvider.rx
            .request(.getRate(rate), callbackQueue: DispatchQueue.global(qos: .background))
            .filterSuccessfulStatusAndRedirectCodes()
            .map(Response.Rate.self)
            .asObservable()
            .map({ (model) -> DomainLayer.DTO.Coinomat.Rate in
                
                let fee = Money(value: Decimal(model.fee_in + model.fee_out), asset.precision)
                let min = Money(value: Decimal(model.in_min), asset.precision)
                let max = Money(value: Decimal(model.in_max), asset.precision)
                return DomainLayer.DTO.Coinomat.Rate(fee: fee, min: min, max: max)
            })
    }
    
    func cardLimits(address: String, fiat: String) -> Observable<DomainLayer.DTO.Coinomat.CardLimit> {
        
        let cardLimit = Coinomat.Service.CardLimit(crypto: GlobalConstants.wavesAssetId,
                                                   address: address,
                                                   fiat: fiat)
        return coinomatProvider.rx
            .request(.cardLimit(cardLimit), callbackQueue: DispatchQueue.global(qos: .background))
            .filterSuccessfulStatusAndRedirectCodes()
            .map(Response.CardLimit.self)
            .asObservable()
            .map({ (limit) -> DomainLayer.DTO.Coinomat.CardLimit in
                let min = Money(value: Decimal(limit.min), GlobalConstants.FiatDecimals)
                let max = Money(value: Decimal(limit.max), GlobalConstants.FiatDecimals)
                return DomainLayer.DTO.Coinomat.CardLimit(min: min, max: max)
            })
    }
    
    func getPrice(address: String, amount: Money, typeId: String) -> Observable<Money> {
        
        let price = Coinomat.Service.Price(fiat: typeId,
                                           address: address,
                                           amount: amount.doubleValue)
        return coinomatProvider.rx
        .request(.getPrice(price), callbackQueue: DispatchQueue.global(qos: .background))
        .filterSuccessfulStatusAndRedirectCodes()
        .asObservable()
        .map({ (response) -> Money in
            
            let string = String(data: response.data, encoding: .utf8) ?? ""
            return Money(value: Decimal((string as NSString).doubleValue), GlobalConstants.WavesDecimals)
        })
        
    }
}
