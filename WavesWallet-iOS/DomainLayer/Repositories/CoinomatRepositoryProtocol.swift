//
//  CoinomatRepositoryProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/13/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol CoinomatRepositoryProtocol {
    func tunnelInfo(currencyFrom: String, currencyTo: String, walletTo: String, moneroPaymentID: String?) -> Observable<DomainLayer.DTO.Coinomat.TunnelInfo>
    func getRate(asset: DomainLayer.DTO.Asset) -> Observable<DomainLayer.DTO.Coinomat.Rate>
    func cardLimits(address: String, fiat: String) -> Observable<DomainLayer.DTO.Coinomat.CardLimit>
    func getPrice(address: String, amount: Money, type: String) -> Observable<Money>
    func generateBuyLink(address: String, amount: Double, fiat: String) -> Observable<String>
}
