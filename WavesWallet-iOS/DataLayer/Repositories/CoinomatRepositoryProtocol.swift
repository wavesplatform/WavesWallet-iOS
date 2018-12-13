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
    func tunnelInfo(currencyFrom: String, currencyTo: String, walletTo: String, moneroPaymentID: String?) -> Observable<Int>
    func getRate(from: String, to: String) -> Observable<Int>
    func getLimits(crypto: String, address: String, fiat: String) -> Observable<Int>
}
