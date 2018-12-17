//
//  DexOrderBookRepositoryProtocol.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 12/17/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxSwift

protocol DexOrderBookRepositoryProtocol {
    
    func orderBook(amountAsset: String, priceAsset: String) -> Observable<API.DTO.OrderBook>
}
