//
//  LastTradesRepositoryProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/5/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol LastTradesRepositoryProtocol {
    func lastTrades(amountAsset: DomainLayer.DTO.Dex.Asset, priceAsset: DomainLayer.DTO.Dex.Asset, limit: Int) -> Observable<[DomainLayer.DTO.DexLastTrade]>
}
